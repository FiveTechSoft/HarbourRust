/* Own MIT. OPTIONAL `--harbour-rdd` backend for hbc (Windows x64 only).
 *
 * Implements hbc's DBF seam - the SysV `hrdbf_app_*` entry points that the
 * default mode takes from runtime/hrdbf_app.c - on top of Harbour 3.2's own
 * VM + RDD (DBFCDX/DBFNTX/DBFFPT), plus the write/index entries only this
 * mode emits. Harbour is linked, not copied: GPL with the Harbour linking
 * exception (docs/HARBOUR-RDD-2026-11-16.md). hbc never references these
 * symbols unless `--harbour-rdd` is given; default builds are unchanged.
 *
 * hbc compiles this file with the MinGW gcc found at link time:
 *   gcc -c -O2 -I<harbour>/include -I<tmp> hrharbour_rdd.c   [-DHR_HB_DLL]
 * Process shape: the exe starts in the MinGW CRT (mainCRTStartup), main()
 * below registers the symbols it calls, selects the CGI GT, starts the VM
 * without a PRG main and calls hbc's own `_start`. Every hbc exit path
 * calls hr_hb_exitprocess instead of ExitProcess, so hb_vmQuit closes and
 * flushes every work area first.
 *
 * Errors raised inside Harbour (RDD, FieldPut, ...) go through a low-level
 * error handler that follows Harbour's ErrorSys defaults (zero divide -> 0,
 * lock retry, NetErr for shared open/append-lock) and otherwise formats
 * the ErrorSys message plus Harbour's own call frames, then hands it to
 * hbc's hrm_fail, which appends hbc's frames and exits 1 (headless
 * terminal profile, docs/MACRO-ERROR-CONTRACT.md: no Alert line). */
#include "hbapi.h"
#include "hbapiitm.h"
#include "hbapirdd.h"
#include "hbapierr.h"
#include "hbapigt.h"
#include "hbvm.h"
#include "hbstack.h"
#include <windows.h>
#include <math.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include "hrdyn.h"
#include "hrvalue.h"
#include "hrvalue.c"

#define HR_SYSV __attribute__((sysv_abi, force_align_arg_pointer))
typedef void *(__attribute__((sysv_abi)) *hr_copy_fn)(const void *, size_t);

/* hbc side (emitted assembly, SysV). */
extern void __attribute__((sysv_abi)) _start( void );
extern void __attribute__((sysv_abi, noreturn)) hrm_fail( const char *, size_t );

/* C-level HB_FUNCs are not dynamic symbols until a module registers them.
 * Register (and so force-link) everything called by name, the RDDs and
 * ErrorSys (hb_vmInit runs it; the error block must exist). */
HB_FUNC_EXTERN( DBFCDX ); HB_FUNC_EXTERN( DBFNTX ); HB_FUNC_EXTERN( DBFFPT );
HB_FUNC_EXTERN( DBUSEAREA ); HB_FUNC_EXTERN( DBCLOSEAREA ); HB_FUNC_EXTERN( DBGOTOP );
HB_FUNC_EXTERN( DBGOBOTTOM ); HB_FUNC_EXTERN( DBGOTO ); HB_FUNC_EXTERN( DBSKIP ); HB_FUNC_EXTERN( FIELDGET );
HB_FUNC_EXTERN( FIELDPUT ); HB_FUNC_EXTERN( FIELDPOS ); HB_FUNC_EXTERN( RECNO ); HB_FUNC_EXTERN( LASTREC );
HB_FUNC_EXTERN( BOF ); HB_FUNC_EXTERN( EOF ); HB_FUNC_EXTERN( DELETED ); HB_FUNC_EXTERN( FOUND );
HB_FUNC_EXTERN( DBSEEK ); HB_FUNC_EXTERN( ORDLISTADD ); HB_FUNC_EXTERN( ORDLISTCLEAR );
HB_FUNC_EXTERN( DBAPPEND ); HB_FUNC_EXTERN( ORDCREATE ); HB_FUNC_EXTERN( ORDSETFOCUS ); HB_FUNC_EXTERN( DBCOMMIT );
HB_FUNC_EXTERN( DBDELETE ); HB_FUNC_EXTERN( DBRECALL ); HB_FUNC_EXTERN( ERRORSYS ); HB_FUNC_EXTERN( HB_GT_CGI_DEFAULT );

#define HR_SYM( n ) { #n, { HB_FS_PUBLIC }, { HB_FUNCNAME( n ) }, NULL }
static HB_SYMB hr_hb_symbols[] = {
   HR_SYM( DBUSEAREA ), HR_SYM( DBCLOSEAREA ), HR_SYM( DBGOTOP ), HR_SYM( DBGOBOTTOM ), HR_SYM( DBGOTO ),
   HR_SYM( DBSKIP ), HR_SYM( FIELDGET ), HR_SYM( FIELDPUT ), HR_SYM( FIELDPOS ), HR_SYM( RECNO ),
   HR_SYM( LASTREC ), HR_SYM( BOF ), { "EOF", { HB_FS_PUBLIC }, { HB_FUN_EOF }, NULL },
   HR_SYM( DELETED ), HR_SYM( FOUND ), HR_SYM( DBSEEK ), HR_SYM( ORDLISTADD ), HR_SYM( ORDLISTCLEAR ),
   HR_SYM( DBAPPEND ), HR_SYM( ORDCREATE ), HR_SYM( ORDSETFOCUS ), HR_SYM( DBCOMMIT ),
   HR_SYM( DBDELETE ), HR_SYM( DBRECALL ), HR_SYM( ERRORSYS ),
   HR_SYM( DBFCDX ), HR_SYM( DBFNTX ), HR_SYM( DBFFPT ), HR_SYM( HB_GT_CGI_DEFAULT ) };

#ifndef HR_HB_DLL
/* rtl/gtsys.c names GTWIN as the Windows default GT; satisfy that reference
 * without linking the console GT (CGI is selected explicitly in main). */
HB_FUNC( HB_GT_WIN ) {}
#endif

static int hr_hb_up;

static void hr_write_err( const char * msg )
{
   DWORD w; WriteFile( GetStdHandle( STD_ERROR_HANDLE ), msg, ( DWORD ) strlen( msg ), &w, 0 );
}
/* Internal invariant failures only (never a Harbour run-time error). */
static void hr_fail( const char * msg )
{
   hr_write_err( msg );
   if( hr_hb_up ) { hr_hb_up = 0; hb_vmQuit(); }
   ExitProcess( 1 );
}

/* ---------- Harbour run-time errors ---------- */
static void hr_cat( char * b, size_t cap, size_t * n, const char * s )
{
   while( *s && *n + 1 < cap ) b[ ( *n )++ ] = *s++;
   b[ *n ] = 0;
}
static HB_ERROR_HANDLE( hr_hb_error )
{
   PHB_ITEM e = ErrorInfo->Error;
   HB_ERRCODE gen = hb_errGetGenCode( e ), os = hb_errGetOsCode( e );
   HB_USHORT fl = hb_errGetFlags( e );
   char msg[ 4096 ], num[ 32 ], name[ HB_SYMBOL_NAME_LEN + 1 ];
   size_t n = 0; int lvl; HB_USHORT line;
   const char * s;
   /* ErrorSys DefError() defaults, in its order. */
   if( gen == 5 && ( fl & EF_CANSUBSTITUTE ) ) return hb_itemPutNI( NULL, 0 );   /* EG_ZERODIV */
   if( gen == 41 && ( fl & EF_CANRETRY ) ) return hb_itemPutL( NULL, HB_TRUE );   /* EG_LOCK */
   if( ( gen == 21 && os == 32 && ( fl & EF_CANDEFAULT ) ) ||                    /* EG_OPEN */
       ( gen == 40 && ( fl & EF_CANDEFAULT ) ) )                                  /* EG_APPENDLOCK */
   {
      hb_rddSetNetErr( HB_TRUE );
      return hb_itemPutL( NULL, HB_FALSE );
   }
   /* ErrorMessage(): "Error SUB/code  description: filename|operation". */
   hr_cat( msg, sizeof msg, &n, hb_errGetSeverity( e ) > 1 ? "Error " : "Warning " );
   s = hb_errGetSubSystem( e ); hr_cat( msg, sizeof msg, &n, s ? s : "???" );
   snprintf( num, sizeof num, "/%d", ( int ) hb_errGetSubCode( e ) ); hr_cat( msg, sizeof msg, &n, num );
   s = hb_errGetDescription( e ); if( s ) { hr_cat( msg, sizeof msg, &n, "  " ); hr_cat( msg, sizeof msg, &n, s ); }
   s = hb_errGetFileName( e );
   if( s && *s ) { hr_cat( msg, sizeof msg, &n, ": " ); hr_cat( msg, sizeof msg, &n, s ); }
   else if( ( s = hb_errGetOperation( e ) ) != NULL && *s ) { hr_cat( msg, sizeof msg, &n, ": " ); hr_cat( msg, sizeof msg, &n, s ); }
   if( os ) { snprintf( num, sizeof num, " (DOS Error %d)", ( int ) os ); hr_cat( msg, sizeof msg, &n, num ); }
   /* Harbour's own frames (e.g. DBUSEAREA(0)); hbc's frames follow in hrm_fail. */
   for( lvl = 0; hb_procinfo( lvl, name, &line, NULL ) && name[ 0 ]; lvl++ )
   {
      snprintf( num, sizeof num, "(%u)  ", ( unsigned ) line );
      hr_cat( msg, sizeof msg, &n, "\r\nCalled from " ); hr_cat( msg, sizeof msg, &n, name ); hr_cat( msg, sizeof msg, &n, num );
   }
   hrm_fail( msg, n );   /* exits through hr_hb_exitprocess(1) */
}
static HB_ERROR_INFO hr_hb_errinfo = { hr_hb_error, NULL, NULL, NULL, NULL };

/* ---------- process lifetime ---------- */
int main( int argc, char * argv[] )
{
   hb_vmProcessSymbols( hr_hb_symbols, ( HB_USHORT ) HB_SIZEOFARRAY( hr_hb_symbols ), "HRHARBOUR_RDD", 0, 0 );
   hb_gtSetDefault( "CGI" );   /* the GTWIN default costs ~65 ms of startup (measured) */
   hb_cmdargInit( argc, argv );
   hb_vmInit( HB_FALSE );      /* VM, symbols, GT, ErrorSys; no PRG main */
   hb_errorHandler( &hr_hb_errinfo );
   hr_hb_up = 1;
   _start();
   return 0;
}
/* hbc's emitted code calls this (MS ABI, ecx = exit code) instead of
 * ExitProcess on every exit path. */
void hr_hb_exitprocess( UINT code )
{
   if( hr_hb_up ) { hr_hb_up = 0; hb_vmQuit(); }
   ExitProcess( code );
}

/* Every call into a Harbour function goes through here. A QUIT requested
 * inside the call (none from the handler above, but any Harbour code path
 * may request one) is honoured now, with Harbour's ERRORLEVEL. */
static PHB_ITEM hr_doC( const char * f, HB_ULONG n, ... )
{
   PHB_ITEM a[ 8 ]; HB_ULONG i; va_list v;
   PHB_DYNS s = hb_dynsymFindName( f );
   if( ! s || n > 8 ) hr_fail( "hbc: harbour-rdd symbol not linked\n" );
   va_start( v, n ); for( i = 0; i < n; i++ ) a[ i ] = va_arg( v, PHB_ITEM ); va_end( v );
   hb_vmPushDynSym( s ); hb_vmPushNil();
   for( i = 0; i < n; i++ ) hb_vmPush( a[ i ] );
   hb_vmProc( ( HB_USHORT ) n );
   if( hb_vmRequestQuery() ) { int rc; hr_hb_up = 0; rc = hb_vmQuit(); ExitProcess( ( UINT ) rc ); }
   return hb_itemNew( hb_stackReturnItem() );
}

/* ---------- Harbour item <-> hbc Dyn cell ---------- */
static hrv_cell hr_cell( PHB_ITEM p, hr_copy_fn copy )
{
   hrv_cell c = { HRV_NIL, 0 };
   if( HB_IS_STRING( p ) || HB_IS_MEMO( p ) )
   {
      c.tag = HRV_STR_OWN; c.payload = ( uint64_t ) copy( hb_itemGetCPtr( p ), hb_itemGetCLen( p ) );
      if( ! c.payload ) hr_fail( "hbc: harbour-rdd string allocation failed\n" );
   }
   else if( HB_IS_NUMERIC( p ) )
   {
      int w, d; hb_itemGetNLen( p, &w, &d );
      if( w < 1 ) w = 1;
      if( d > 0 )
      {
         /* Harbour's item width counts integer digits only; hbc's scalar
          * numeric cell (hrv_number) carries the DBF field width. */
         double v = hb_itemGetND( p ); int i;
         for( i = 0; i < d; i++ ) v *= 10.0;
         w += d + 1;
         return hrv_number( ( int64_t ) llround( v ), ( unsigned ) w, ( unsigned ) d );
      }
      return hrv_number( ( int64_t ) hb_itemGetNInt( p ), ( unsigned ) w, 0 );
   }
   else if( HB_IS_DATE( p ) )
   {
      char s[ 9 ]; uint32_t v = 0; int i; hb_itemGetDS( p, s );
      if( s[ 0 ] != ' ' ) for( i = 0; i < 8; i++ ) v = v * 10 + ( uint32_t ) ( s[ i ] - '0' );
      return hrv_date( v );
   }
   else if( HB_IS_LOGICAL( p ) ) { c.tag = HRV_LOGICAL; c.payload = hb_itemGetL( p ) ? 1 : 0; }
   else if( ! HB_IS_NIL( p ) ) hr_fail( "hbc: harbour-rdd value type outside the admitted subset (C/N/D/L/M)\n" );
   return c;
}
/* hbc cell -> new Harbour item (the caller keeps ownership of the cell). */
static PHB_ITEM hr_item( uint64_t tag, uint64_t pay )
{
   switch( tag & 255u )
   {
      case HRV_I64: case HRV_I64_LITERAL: return hb_itemPutNInt( NULL, ( HB_MAXINT ) ( int64_t ) pay );
      case HRV_NIL: return hb_itemNew( NULL );
      case HRV_LOGICAL: return hb_itemPutL( NULL, pay != 0 );
      case HRV_STR_BORROW: case HRV_STR_OWN:
         if( ! pay ) return hb_itemPutC( NULL, "" );
         return hb_itemPutCL( NULL, ( const char * ) pay, ( HB_SIZE ) ( ( const uint64_t * ) pay )[ -1 ] );
      case HRV_DOUBLE:
      {
         union { uint64_t u; double d; } v;
         v.u = ( tag & HR_DYN_FLOAT_HEAP ) ? ( ( const uint64_t * ) pay )[ 0 ] : pay;
         return hb_itemPutND( NULL, v.d );
      }
      case HRV_DATE:
      {
         char s[ 9 ];
         if( ! pay ) return hb_itemPutDS( NULL, NULL );
         snprintf( s, sizeof s, "%08u", ( unsigned ) pay );
         return hb_itemPutDS( NULL, s );
      }
      case HRV_FIELD_NUMERIC:
      {
         hrv_cell c = { tag, pay }; unsigned d = hrv_decimals( c ), i; double v = ( double ) ( int64_t ) pay;
         if( ! d ) return hb_itemPutNIntLen( NULL, ( HB_MAXINT ) ( int64_t ) pay, ( int ) hrv_width( c ) );
         for( i = 0; i < d; i++ ) v /= 10.0;
         return hb_itemPutNDLen( NULL, v, ( int ) ( hrv_width( c ) > d ? hrv_width( c ) - d - 1 : 1 ), ( int ) d );
      }
   }
   hr_fail( "hbc: harbour-rdd value type outside the admitted subset (C/N/D/L)\n" );
   return NULL;
}
static PHB_ITEM hr_str( const unsigned char * p, size_t n ) { return hb_itemPutCL( NULL, ( const char * ) p, ( HB_SIZE ) n ); }
static void hr_do0( const char * f ) { hb_itemRelease( hr_doC( f, 0 ) ); }
static uint64_t hr_bool0( const char * f ) { PHB_ITEM r = hr_doC( f, 0 ); uint64_t v = hb_itemGetL( r ) ? 1 : 0; hb_itemRelease( r ); return v; }
static uint64_t hr_num0( const char * f ) { PHB_ITEM r = hr_doC( f, 0 ); uint64_t v = ( uint64_t ) hb_itemGetNInt( r ); hb_itemRelease( r ); return v; }

/* ---------- the seam: same names and ABI as runtime/hrdbf_app.c ---------- */
/* hbc also calls close after Main and on its panic path. */
HR_SYSV void hrdbf_app_close( void ) { if( hr_hb_up ) hr_do0( "DBCLOSEAREA" ); }
/* flags: bit0 new area, bit1 DBFCDX (else DBFNTX), bit2 shared, bit3 readonly. */
HR_SYSV void hrdbf_app_open6( const unsigned char * p, size_t len, uint64_t flags, const unsigned char * a, size_t alen )
{
   PHB_ITEM n = hb_itemPutL( NULL, ( flags & 1 ) != 0 ), d = hb_itemPutC( NULL, ( flags & 2 ) ? "DBFCDX" : "DBFNTX" ), f = hr_str( p, len );
   PHB_ITEM al = alen ? hr_str( a, alen ) : hb_itemNew( NULL ), sh = hb_itemPutL( NULL, ( flags & 4 ) != 0 ), ro = hb_itemPutL( NULL, ( flags & 8 ) != 0 );
   hb_itemRelease( hr_doC( "DBUSEAREA", 6, n, d, f, al, sh, ro ) );
   hb_itemRelease( n ); hb_itemRelease( d ); hb_itemRelease( f ); hb_itemRelease( al ); hb_itemRelease( sh ); hb_itemRelease( ro );
}
HR_SYSV void hrdbf_app_top( void ) { hr_do0( "DBGOTOP" ); }
HR_SYSV void hrdbf_app_bottom( void ) { hr_do0( "DBGOBOTTOM" ); }
HR_SYSV void hrdbf_app_skip( int64_t k ) { PHB_ITEM n = hb_itemPutNInt( NULL, k ); hb_itemRelease( hr_doC( "DBSKIP", 1, n ) ); hb_itemRelease( n ); }
HR_SYSV void hrdbf_app_goto( int64_t k ) { PHB_ITEM n = hb_itemPutNInt( NULL, k ); hb_itemRelease( hr_doC( "DBGOTO", 1, n ) ); hb_itemRelease( n ); }
HR_SYSV void hrdbf_app_ordselect( int64_t k ) { PHB_ITEM n = hb_itemPutNInt( NULL, k ); hb_itemRelease( hr_doC( "DBSETORDER", 1, n ) ); hb_itemRelease( n ); }
HR_SYSV uint64_t hrdbf_app_order_add( const unsigned char * p, size_t len ) { PHB_ITEM f = hr_str( p, len ); PHB_ITEM r = hr_doC( "ORDLISTADD", 1, f ); uint64_t v = hb_itemGetL( r ); hb_itemRelease( r ); hb_itemRelease( f ); return v; }
HR_SYSV void hrdbf_app_order_clear( void ) { hr_do0( "ORDLISTCLEAR" ); }
HR_SYSV uint64_t hrdbf_app_found( void ) { return hr_bool0( "FOUND" ); }
HR_SYSV uint64_t hrdbf_app_seek( const unsigned char * p, size_t n, uint64_t soft, uint64_t last )
{
   PHB_ITEM k = hr_str( p, n ), s = hb_itemPutL( NULL, soft != 0 ), l = hb_itemPutL( NULL, last != 0 );
   PHB_ITEM r = hr_doC( "DBSEEK", 3, k, s, l ); uint64_t v = hb_itemGetL( r );
   hb_itemRelease( r ); hb_itemRelease( k ); hb_itemRelease( s ); hb_itemRelease( l ); return v;
}
HR_SYSV uint64_t hrdbf_app_recno( void ) { return hr_num0( "RECNO" ); }
HR_SYSV uint64_t hrdbf_app_lastrec( void ) { return hr_num0( "LASTREC" ); }
HR_SYSV uint64_t hrdbf_app_fcount( void ) { return hr_num0( "FCOUNT" ); }
HR_SYSV uint64_t hrdbf_app_bof( void ) { return hr_bool0( "BOF" ); }
HR_SYSV uint64_t hrdbf_app_eof( void ) { return hr_bool0( "EOF" ); }
HR_SYSV uint64_t hrdbf_app_deleted( void ) { return hr_bool0( "DELETED" ); }
HR_SYSV hrv_cell hrdbf_app_get( int64_t n, hr_copy_fn copy )
{
   PHB_ITEM i = hb_itemPutNInt( NULL, n ), r = hr_doC( "FIELDGET", 1, i ); hrv_cell c = hr_cell( r, copy );
   hb_itemRelease( r ); hb_itemRelease( i ); return c;
}
/* Same contract as runtime/hrdbf_fieldpos.c: -1 no work area, 0 no such
 * field, else the 1-based ordinal (current work area). */
HR_SYSV int64_t hrdbf_app_fieldpos( const unsigned char * name, uint64_t len )
{
   AREAP a = ( AREAP ) hb_rddGetCurrentWorkAreaPointer(); char nm[ 64 ]; HB_USHORT i;
   if( ! a ) return -1;
   if( len >= sizeof nm ) return 0;
   memcpy( nm, name, len ); nm[ len ] = 0;
   i = hb_rddFieldIndex( a, nm );
   return ( int64_t ) i;
}
/* alias->: select the alias's area; 0 = no such alias (BASE/1002), else
 * the previous area number for hrdbf_app_area_restore. */
HR_SYSV int64_t hrdbf_app_alias_select( const unsigned char * a, uint64_t alen )
{
   char nm[ 64 ]; int old = hb_rddGetCurrentWorkAreaNumber();
   if( ! alen || alen >= sizeof nm ) return 0;
   memcpy( nm, a, alen ); nm[ alen ] = 0;
   if( hb_rddSelectWorkAreaAlias( nm ) != HB_SUCCESS ) { hb_rddSelectWorkAreaNumber( old ); return 0; }
   if( ! hb_rddGetCurrentWorkAreaPointer() ) { hb_rddSelectWorkAreaNumber( old ); return 0; }
   return old > 0 ? old : 1;
}
HR_SYSV void hrdbf_app_area_restore( int64_t old ) { hb_rddSelectWorkAreaNumber( ( int ) old ); }

/* ---------- writes and orders (emitted only under --harbour-rdd) ---------- */
HR_SYSV void hrdbf_app_append( void ) { hr_do0( "DBAPPEND" ); }
HR_SYSV void hrdbf_app_commit( void ) { hr_do0( "DBCOMMIT" ); }
HR_SYSV void hrdbf_app_delete( void ) { hr_do0( "DBDELETE" ); }
HR_SYSV void hrdbf_app_recall( void ) { hr_do0( "DBRECALL" ); }
/* FieldPut( n, value ): the Harbour function (its frame shows in errors). */
HR_SYSV void hrdbf_app_fieldput( int64_t n, uint64_t tag, uint64_t pay )
{
   PHB_ITEM i = hb_itemPutNInt( NULL, n ), v = hr_item( tag, pay );
   hb_itemRelease( hr_doC( "FIELDPUT", 2, i, v ) ); hb_itemRelease( i ); hb_itemRelease( v );
}
/* NAME := value / ALIAS->NAME := value: the VM's direct field store (no
 * function frame, like Harbour's POPFIELD/POPALIASEDFIELD). */
HR_SYSV void hrdbf_app_put( int64_t n, uint64_t tag, uint64_t pay )
{
   AREAP a = ( AREAP ) hb_rddGetCurrentWorkAreaPointer(); PHB_ITEM v = hr_item( tag, pay );
   if( a ) SELF_PUTVALUE( a, ( HB_USHORT ) n, v );
   hb_itemRelease( v );
   if( hb_vmRequestQuery() ) { int rc; hr_hb_up = 0; rc = hb_vmQuit(); ExitProcess( ( UINT ) rc ); }
}
/* ordCreate( cBag, cTag, cKey ): no block, the RDD macro-compiles cKey. */
HR_SYSV void hrdbf_app_ordcreate( const unsigned char * b, size_t bl, const unsigned char * t, size_t tl, const unsigned char * k, size_t kl )
{
   PHB_ITEM pb = bl ? hr_str( b, bl ) : hb_itemNew( NULL ), pt = tl ? hr_str( t, tl ) : hb_itemNew( NULL ), pk = hr_str( k, kl );
   hb_itemRelease( hr_doC( "ORDCREATE", 3, pb, pt, pk ) );
   hb_itemRelease( pb ); hb_itemRelease( pt ); hb_itemRelease( pk );
}
/* ordSetFocus( cTag ) -> previous order name. */
HR_SYSV hrv_cell hrdbf_app_ordsetfocus( const unsigned char * t, size_t tl, hr_copy_fn copy )
{
   PHB_ITEM pt = hr_str( t, tl ), r = hr_doC( "ORDSETFOCUS", 1, pt ); hrv_cell c = hr_cell( r, copy );
   hb_itemRelease( r ); hb_itemRelease( pt ); return c;
}

/* ---------- pure scalar helpers: identical to runtime/hrdbf_app.c ---------- */
HR_SYSV size_t hrdbf_app_render( uint64_t tag, uint64_t pay, unsigned char * out )
{
   hrv_cell c = { tag, pay }; size_t n = 0;
   if( hrv_render( c, out, 256, &n ) ) hr_fail( "hbc: DBF scalar render rejected\n" );
   return n;
}
HR_SYSV int64_t hrdbf_app_integer( uint64_t tag, uint64_t pay )
{
   hrv_cell c = { tag, pay }; int64_t n; hrv_error e = hrv_i64( c, &n );
   if( e == HRV_DECIMAL_I64 ) hr_fail( "hbc: DBF decimal numeric cannot enter I64 operation\n" );
   if( e ) hr_fail( "hbc: DBF scalar cannot enter I64 operation\n" );
   return n;
}
HR_SYSV uint64_t hrdbf_app_equal( uint64_t ta, uint64_t pa, uint64_t tb, uint64_t pb )
{
   hrv_cell a = { ta, pa }, b = { tb, pb }; int yes;
   if( hrv_equal( a, b, &yes ) ) hr_fail( "hbc: DBF scalar comparison is outside this increment\n" );
   return ( uint64_t ) yes;
}
/* D4: ordering comparisons widen numerics by value (hrv_compare) -
 * identical semantics to the native adapter. */
HR_SYSV int64_t hrdbf_app_compare( uint64_t ta, uint64_t pa, uint64_t tb, uint64_t pb )
{
   hrv_cell a = { ta, pa }, b = { tb, pb }; int64_t r; hrv_error e;
   if( hrv_kind( a ) == HRV_DATE && hrv_kind( b ) == HRV_DATE ) return pa < pb ? -1 : pa > pb;
   e = hrv_compare( a, b, &r ); if( e ) hr_fail( "hbc: DBF scalar comparison is outside this increment\n" );
   return r;
}
HR_SYSV uint64_t hrdbf_app_empty( uint64_t t, uint64_t p )
{
   hrv_cell c = { t, p }; unsigned k = hrv_kind( c ); int yes;
   if( k == HRV_STR_OWN || k == HRV_STR_BORROW )
   {
      size_t i, n = ( ( const uint64_t * ) p )[ -1 ]; const unsigned char * s = ( const unsigned char * ) p;
      for( i = 0; i < n; i++ ) if( s[ i ] != ' ' && s[ i ] != 9 && s[ i ] != 10 && s[ i ] != 13 ) return 0;
      return 1;
   }
   if( k == HRV_ARRAY ) return ! p || ! ( ( const uint64_t * ) p )[ -1 ];
   if( k == HRV_DOUBLE ) { union { uint64_t u; double d; } v; v.u = ( t & HR_DYN_FLOAT_HEAP ) ? ( ( const uint64_t * ) p )[ 0 ] : p; return v.d == 0.0; }
   if( k == HRV_BLOCK ) return 0;
   if( hrv_empty( c, &yes ) ) hr_fail( "hbc: DBF scalar Empty rejected\n" );
   return ( uint64_t ) yes;
}
/* D3: Dyn numeric arithmetic entry point - identical semantics to the
 * native adapter (shared hrv_arith), so both adapters agree cell for cell. */
HR_SYSV hrv_cell hrdbf_app_arith( uint64_t op, uint64_t ta, uint64_t pa, uint64_t tb, uint64_t pb )
{
   hrv_cell a = { ta, pa }, b = { tb, pb }, r; hrv_error e = hrv_arith( ( unsigned ) op, a, b, &r );
   if( e == HRV_ZERODIV ) hr_fail( "hbc: DBF arithmetic division by zero\n" );
   if( e == HRV_TYPE ) hr_fail( "hbc: DBF arithmetic on a NIL or non-numeric operand\n" );
   if( e ) hr_fail( "hbc: DBF arithmetic rejected\n" );
   return r;
}
HR_SYSV void hrdbf_app_unsupported( void ) { hr_fail( "hbc: DBF-active dynamic scalar consumer is outside the admitted subset\n" ); }
