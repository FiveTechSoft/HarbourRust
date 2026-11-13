/* hbhbr.c - HarbourRust Extend-System bridge runtime, milestone 1.
 *
 * HarbourRust's OWN implementation (MIT); no Harbour code. Freestanding:
 * no libc/CRT - raw Linux syscalls or direct kernel32 imports, so the
 * object links into the hbc no-library flow (ld or hbmk2 -nostdlib on
 * Linux, mingw-ld -lkernel32 on Windows). See docs/EXTEND-BRIDGE.md
 * for the contract and the current limits.
 *
 * Build: gcc -c -O2 -ffreestanding -fno-stack-protector hbhbr.c -o hbhbr.o
 *   (Windows: x86_64-w64-mingw32-gcc with the same flags)
 */

#include "hbhbr.h"

/* Provided by the hbc-generated object (exported when EXTERNAL is used):
 * hbc_strcpy(src, len) -> owned buffer copy with its length word at
 * data-8 (the hbc owned-string layout); hbc_freestr(ptr) releases it. */
extern void * hbc_strcpy( const void * src, HB_ULONG len );
extern void   hbc_freestr( void * owned );

#ifdef _WIN32
/* hbc's own helpers keep the hbc-internal argument convention
 * (rdi/rsi) on BOTH targets; a C caller on Windows uses the Win64
 * registers, so the calls route through two standalone asm adapters
 * with an explicit ABI (rcx/rdx -> rdi/rsi), the same discipline as
 * the hbc_blk_launch trampoline (milestone 2.5). Tail jumps: the
 * helper returns straight to the C caller. */
__asm__(
    ".p2align 3\n"
    ".globl hbw_strcpy\n"
    "hbw_strcpy:\n"
    "    mov %rcx, %rdi\n"
    "    mov %rdx, %rsi\n"
    "    jmp hbc_strcpy\n"
    ".globl hbw_freestr\n"
    "hbw_freestr:\n"
    "    mov %rcx, %rdi\n"
    "    jmp hbc_freestr\n" );
extern void * hbw_strcpy( const void * src, HB_ULONG len );
extern void   hbw_freestr( void * owned );
#define hbc_strcpy hbw_strcpy
#define hbc_freestr hbw_freestr
#endif

/* Bridge state, written by hbc_ext_dispatch before every call.
 * hbc_ext_argv points at 16-byte {tag,payload} casillas pushed left to
 * right; argument i (1-based) sits at index 2*(argc-i) / +1. */
HB_ULONG        hbc_ext_argc;
const HB_ULONG *hbc_ext_argv;
HB_ULONG        hbc_ext_ret_tag = 1; /* NIL */
HB_ULONG        hbc_ext_ret_pay = 0;

/* hbc Dyn tags: 0/9 integer, 1 NIL, 2 borrowed string, 3 logical,
 * 4 owned string, 5 double (payload = value bits, no allocation).
 * String payload -> bytes; length word at payload-8. */
#define HBC_TAG_INT     0
#define HBC_TAG_NIL     1
#define HBC_TAG_STR_BRW 2
#define HBC_TAG_LOGICAL 3
#define HBC_TAG_STR_OWN 4
#define HBC_TAG_DOUBLE  5 /* the tag word may carry the decimal count in
                           * its high bits (5 | dec<<8) so a double's
                           * format survives an echo across the bridge;
                           * consumers mask with HBC_TAG_MASK. dec 0 =
                           * the hb_itemPutND default (2). */
#define HBC_TAG_MASK    0xFF
#define HBC_TAG_SUBARR  6 /* owned subarray cell: payload = child block */
#define HBC_TAG_ARRAY   8 /* Dyn-held array: count at payload-8, cells at payload */
#define HBC_TAG_INT_LIT 9
#define HBC_TAG_BLOCK   7  /* codeblock: payload = code pointer (2.5) */
#define HBC_TAG_BYREF   10 /* marker: payload = address of the caller casilla */

/* The raw casilla of argument i, or NULL when omitted. */
static const HB_ULONG * cell_raw( int i )
{
    if( i < 1 || (HB_ULONG) i > hbc_ext_argc ) return (const HB_ULONG *) 0;
    return hbc_ext_argv + 2 * ( hbc_ext_argc - (HB_ULONG) i );
}
/* The value casilla: a byref argument reads through to the caller's. */
static const HB_ULONG * cell_ptr( int i )
{
    const HB_ULONG * cas = cell_raw( i );
    if( cas && cas[ 0 ] == HBC_TAG_BYREF ) return (const HB_ULONG *) cas[ 1 ];
    return cas;
}
static HB_ULONG cell_tag( int i )
{
    const HB_ULONG * cas = cell_ptr( i );
    return cas ? ( cas[ 0 ] & HBC_TAG_MASK ) : HBC_TAG_NIL;
}
static HB_ULONG cell_pay( int i )
{
    const HB_ULONG * cas = cell_ptr( i );
    return cas ? cas[ 1 ] : 0;
}

int hb_pcount( void ) { return (int) hbc_ext_argc; }

HB_ULONG hb_parinfo( int iParam )
{
    HB_ULONG t;
    const HB_ULONG * raw;
    if( iParam == 0 ) return hbc_ext_argc; /* Harbour: param count */
    raw = cell_raw( iParam );
    switch( cell_tag( iParam ) )
    {
        case HBC_TAG_INT:
        case HBC_TAG_INT_LIT: {
            /* Harbour oracle: a whole number inside the 32-bit range is
             * HB_IT_INTEGER (42 -> 2), beyond it HB_IT_LONG
             * (2147483648 -> 8). */
            HB_LONG v = (HB_LONG) cell_pay( iParam );
            t = ( v >= -2147483648L && v <= 2147483647L ) ? HB_IT_INTEGER : HB_IT_LONG;
            break;
        }
        case HBC_TAG_DOUBLE:  t = HB_IT_DOUBLE; break;
        case HBC_TAG_LOGICAL: t = HB_IT_LOGICAL; break;
        case HBC_TAG_STR_BRW:
        case HBC_TAG_STR_OWN: t = HB_IT_STRING; break;
        case HBC_TAG_SUBARR:
        case HBC_TAG_ARRAY:   t = HB_IT_ARRAY; break;
        case HBC_TAG_BLOCK:   t = HB_IT_BLOCK; break;
        default:              t = HB_IT_NIL; break;
    }
    /* A byref argument carries HB_IT_BYREF over the referred type. */
    if( raw && raw[ 0 ] == HBC_TAG_BYREF ) t |= HB_IT_BYREF;
    return t;
}


int hb_extIsNil( int iParam ) { return cell_tag( iParam ) == HBC_TAG_NIL; }

/* Arrays, read-only (milestone 2.4). An array casilla (tag 8, or tag 6
 * for an owned subarray cell) keeps the element count at payload-8 and
 * the 16-byte {tag,payload} cells at payload. Handles are borrowed and
 * read-only; an out-of-range index or a non-array yields NULL/0. */
static HB_ULONG tag_to_type( HB_ULONG t, HB_ULONG pay );

static const HB_ULONG * arr_cells( const HB_ULONG * w )
{
    /* An @array argument arrives as the byref marker: read through ONE
     * hop, so hb_arrayLen( hb_param( i, HB_IT_ARRAY ) ) works on @a
     * exactly like real Harbour extension code expects. */
    if( w && w[ 0 ] == HBC_TAG_BYREF && w[ 1 ] )
        w = (const HB_ULONG *) w[ 1 ];
    if( ! w || ( w[ 0 ] != HBC_TAG_ARRAY && w[ 0 ] != HBC_TAG_SUBARR ) || ! w[ 1 ] )
        return (const HB_ULONG *) 0;
    return (const HB_ULONG *) w[ 1 ];
}

HB_SIZE hb_arrayLen( PHB_ITEM pItem )
{
    const HB_ULONG * cells = arr_cells( (const HB_ULONG *) pItem );
    return cells ? (HB_SIZE) cells[ -1 ] : 0;
}

static PHB_ITEM arr_elem( const HB_ULONG * w, HB_SIZE nIndex )
{
    const HB_ULONG * cells = arr_cells( w );
    if( ! cells || nIndex < 1 || nIndex > (HB_SIZE) cells[ -1 ] ) return (PHB_ITEM) 0;
    return (PHB_ITEM)( cells + 2 * ( nIndex - 1 ) );
}

PHB_ITEM hb_arrayGetItemPtr( PHB_ITEM pArray, HB_SIZE nIndex )
{
    return arr_elem( (const HB_ULONG *) pArray, nIndex );
}

/* Harbour has no hb_parna: the canonical pattern is
 * hb_param( i, HB_IT_ARRAY ) + the hb_arrayGet* readers below. */
HB_SIZE hb_parinfa( int iParamNum, HB_SIZE nArrayIndex )
{
    const HB_ULONG * cells = arr_cells( cell_raw( iParamNum ) );
    if( ! cells ) return 0;
    if( nArrayIndex == 0 ) return (HB_SIZE) cells[ -1 ]; /* length */
    if( nArrayIndex > (HB_SIZE) cells[ -1 ] ) return 0;
    return (HB_SIZE) tag_to_type( cells[ 2 * ( nArrayIndex - 1 ) ], cells[ 2 * ( nArrayIndex - 1 ) + 1 ] );
}

HB_TYPE hb_arrayGetType( PHB_ITEM pArray, HB_SIZE nIndex )
{
    const HB_ULONG * e = (const HB_ULONG *) arr_elem( (const HB_ULONG *) pArray, nIndex );
    return e ? tag_to_type( e[ 0 ], e[ 1 ] ) : HB_IT_NIL;
}
int    hb_arrayGetNI( PHB_ITEM pArray, HB_SIZE nIndex ) { return hb_itemGetNI( hb_arrayGetItemPtr( pArray, nIndex ) ); }
HB_LONG   hb_arrayGetNL( PHB_ITEM pArray, HB_SIZE nIndex ) { return hb_itemGetNL( hb_arrayGetItemPtr( pArray, nIndex ) ); }
double hb_arrayGetND( PHB_ITEM pArray, HB_SIZE nIndex ) { return hb_itemGetND( hb_arrayGetItemPtr( pArray, nIndex ) ); }
HB_BOOL hb_arrayGetL( PHB_ITEM pArray, HB_SIZE nIndex ) { return hb_itemGetL( hb_arrayGetItemPtr( pArray, nIndex ) ); }
char * hb_arrayGetC( PHB_ITEM pArray, HB_SIZE nIndex )  { return hb_itemGetC( hb_arrayGetItemPtr( pArray, nIndex ) ); }
HB_SIZE hb_arrayGetCLen( PHB_ITEM pArray, HB_SIZE nIndex ) { return hb_itemGetCLen( hb_arrayGetItemPtr( pArray, nIndex ) ); }

PHB_ITEM hb_param( int iParam, HB_LONG lMask )
{
    /* Harbour oracle: an argument PRESENT with value NIL answers
     * non-NULL for HB_IT_ANY; an OMITTED argument answers NULL. The
     * handle IS the argument's {tag,payload} casilla (milestone 2.1:
     * read-only through the item API; hb_itemNew() copies it). */
    const HB_ULONG * cas;
    if( iParam < 1 || (HB_ULONG) iParam > hbc_ext_argc ) return (PHB_ITEM) 0;
    cas = hbc_ext_argv + 2 * ( hbc_ext_argc - (HB_ULONG) iParam );
    if( cas[ 0 ] == HBC_TAG_NIL )
        return lMask == (HB_LONG) HB_IT_ANY ? (PHB_ITEM) cas : (PHB_ITEM) 0;
    return ( hb_parinfo( iParam ) & (HB_ULONG) lMask ) ? (PHB_ITEM) cas : (PHB_ITEM) 0;
}

HB_LONG hb_parnl( int iParam )
{
    HB_ULONG t = cell_tag( iParam );
    if( t == HBC_TAG_INT || t == HBC_TAG_INT_LIT ) return (HB_LONG) cell_pay( iParam );
    if( t == HBC_TAG_DOUBLE ) { union { HB_ULONG b; double d; } u; u.b = cell_pay( iParam ); return (HB_LONG) u.d; }
    return 0; /* Harbour answers 0 on a type mismatch at this API level */
}

double hb_parnd( int iParam )
{
    HB_ULONG t = cell_tag( iParam );
    if( t == HBC_TAG_INT || t == HBC_TAG_INT_LIT ) return (double) (HB_LONG) cell_pay( iParam );
    if( t == HBC_TAG_DOUBLE ) { union { HB_ULONG b; double d; } u; u.b = cell_pay( iParam ); return u.d; }
    return 0.0; /* Harbour answers 0 on a type mismatch at this API level */
}
int hb_parni( int iParam ) { return (int) hb_parnl( iParam ); }

int hb_parl( int iParam )
{
    return cell_tag( iParam ) == HBC_TAG_LOGICAL && cell_pay( iParam ) != 0;
}

/* --- scratch copies (hb_parc), freed by hbc_ext_end after the call --- */

/* Platform backends (milestone 2.6). The object stays freestanding on
 * both targets: raw syscalls on Linux, direct kernel32 imports on
 * Windows (no CRT either way), so it links into the hbc no-library
 * flow (ld / hbmk2 -nostdlib on Linux, mingw-ld -lkernel32 on
 * Windows). The sys_* names below keep their Linux flavour; each is a
 * one-line shim over the platform primitive. */
#ifndef _WIN32
static void * sys_mmap( HB_ULONG len )
{
    void * ret;
    register HB_LONG r10 __asm__( "r10" ) = 0x22; /* MAP_PRIVATE|MAP_ANONYMOUS */
    register HB_LONG r8  __asm__( "r8" )  = -1;
    register HB_LONG r9  __asm__( "r9" )  = 0;
    __asm__ volatile( "syscall"
        : "=a"( ret )
        : "a"( 9L ), "D"( 0L ), "S"( len ), "d"( 3L ), "r"( r10 ), "r"( r8 ), "r"( r9 )
        : "rcx", "r11", "memory" );
    return ret;
}
static void sys_munmap( void * addr, HB_ULONG len )
{
    register HB_LONG rsi __asm__( "rsi" ) = (HB_LONG) len;
    long result;
    __asm__ volatile( "syscall"
        : "=a"( result )
        : "0"( 11L ), "D"( addr ), "r"( rsi )
        : "rcx", "r11", "memory" );
    (void) result;
}
static void sys_write_err( const char * msg, HB_ULONG len )
{
    register HB_LONG rsi __asm__( "rsi" ) = (HB_LONG) msg;
    register HB_LONG rdx __asm__( "rdx" ) = (HB_LONG) len;
    __asm__ volatile( "syscall"
        : /* no output */
        : "a"( 1L ), "D"( 2L ), "r"( rsi ), "r"( rdx )
        : "rcx", "r11", "memory" );
}
static void sys_exit1( void )
{
    __asm__ volatile( "syscall"
        : /* no output */
        : "a"( 60L ), "D"( 1L )
        : "rcx", "r11", "memory" );
    __builtin_unreachable();
}
#define HBC_MAP_FAILED( p ) ( (HB_ULONG) ( p ) > (HB_ULONG) -4096 )
#else /* _WIN32 */
/* Declared by hand (freestanding: no windows.h). DWORD is 32-bit even
 * on Win64; sizes and pointers are 64-bit. __stdcall is a no-op on
 * x86-64 and kept as documentation of the import convention. */
__attribute__( ( dllimport ) ) void *  __stdcall VirtualAlloc( void * addr, HB_ULONG size, unsigned int type, unsigned int prot );
__attribute__( ( dllimport ) ) int     __stdcall VirtualFree( void * addr, HB_ULONG size, unsigned int type );
__attribute__( ( dllimport ) ) void *  __stdcall GetStdHandle( unsigned int which );
__attribute__( ( dllimport ) ) int     __stdcall WriteFile( void * h, const void * buf, unsigned int len, unsigned int * written, void * overlapped );
__attribute__( ( dllimport ) ) __attribute__( ( noreturn ) ) void __stdcall ExitProcess( unsigned int code );
static void * sys_mmap( HB_ULONG len )
{
    /* MEM_COMMIT|MEM_RESERVE, PAGE_READWRITE */
    return VirtualAlloc( (void *) 0, len, 0x3000u, 0x04u );
}
static void sys_munmap( void * addr, HB_ULONG len )
{
    (void) len; /* MEM_RELEASE frees the whole reservation */
    VirtualFree( addr, 0, 0x8000u );
}
static void sys_write_err( const char * msg, HB_ULONG len )
{
    unsigned int wr;
    WriteFile( GetStdHandle( (unsigned int) -12 ), msg, (unsigned int) len, &wr, (void *) 0 ); /* STD_ERROR_HANDLE */
}
static void sys_exit1( void )
{
    ExitProcess( 1u );
}
#define HBC_MAP_FAILED( p ) ( ( p ) == (void *) 0 )
#endif

#define HBC_EXT_SCRATCH_MAX 256
static void * scratch[ HBC_EXT_SCRATCH_MAX ];
static int    scratch_n;

static void * scratch_alloc( HB_ULONG len )
{
    /* 8-byte header holds the mmap length so scratch_free needs nothing
     * else; the returned pointer is the byte after the header. */
    HB_ULONG total = ( len + 8 + 4095 ) & ~(HB_ULONG) 4095;
    void * base;
    if( scratch_n >= HBC_EXT_SCRATCH_MAX ) return (void *) 0;
    base = sys_mmap( total );
    if( HBC_MAP_FAILED( base ) ) return (void *) 0;
    *(HB_ULONG *) base = total;
    scratch[ scratch_n++ ] = base;
    return (char *) base + 8;
}

/* Called by hbc_ext_dispatch after the C function returns. */
void hbc_ext_end( void )
{
    while( scratch_n > 0 )
    {
        void * base = scratch[ --scratch_n ];
        sys_munmap( base, *(HB_ULONG *) base );
    }
}

const char * hb_parc( int iParam )
{
    HB_ULONG t = cell_tag( iParam );
    const char * src;
    char * buf;
    HB_ULONG len, k;
    if( t != HBC_TAG_STR_BRW && t != HBC_TAG_STR_OWN ) return (const char *) 0; /* Harbour: NULL */
    src = (const char *) cell_pay( iParam );
    len = ( (const HB_ULONG *) src )[ -1 ];
    buf = (char *) scratch_alloc( len + 1 );
    if( ! buf ) return "";
    for( k = 0; k < len; k++ ) buf[ k ] = src[ k ];
    buf[ len ] = 0;
    return buf;
}

HB_SIZE hb_parclen( int iParam )
{
    HB_ULONG t = cell_tag( iParam );
    if( t != HBC_TAG_STR_BRW && t != HBC_TAG_STR_OWN ) return 0;
    return ( (const HB_ULONG *) cell_pay( iParam ) )[ -1 ];
}

/* --- return value --- */

/* Every write to the return channel goes through ret_set: a previous
 * OWNED string is released before the channel is overwritten, so
 * calling hb_retc/hb_itemReturn more than once in one C call does not
 * leak the intermediate copies (review v3). */
static void ret_set( HB_ULONG tag, HB_ULONG pay )
{
    if( hbc_ext_ret_tag == HBC_TAG_STR_OWN && hbc_ext_ret_pay )
        hbc_freestr( (void *) hbc_ext_ret_pay );
    hbc_ext_ret_tag = tag; hbc_ext_ret_pay = pay;
}

void hb_ret( void ) { ret_set( HBC_TAG_NIL, 0 ); }

void hb_retl( int iTrueFalse )
{
    ret_set( HBC_TAG_LOGICAL, iTrueFalse ? 1 : 0 );
}
void hb_retni( int iNumber )
{
    ret_set( HBC_TAG_INT, (HB_ULONG) (HB_LONG) iNumber );
}
void hb_retnl( HB_LONG lNumber )
{
    ret_set( HBC_TAG_INT, (HB_ULONG) lNumber );
}
void hb_retclen( const char * szText, HB_SIZE nLen )
{
    static const char empty = 0;
    void * owned;
    /* Harbour oracle: a NULL pointer returns the EMPTY string
     * (ValType "C"), not NIL. */
    if( ! szText ) { szText = &empty; nLen = 0; }
    /* The copy is an hbc-owned string: the Harbour caller takes
     * ownership and releases it with the usual Dyn discipline, so
     * returned strings neither leak nor alias the extension. */
    owned = hbc_strcpy( szText, nLen );
    ret_set( HBC_TAG_STR_OWN, (HB_ULONG) owned );
}
void hb_retnd( double dNumber )
{
    union { double d; HB_ULONG b; } u;
    u.d = dNumber;
    ret_set( HBC_TAG_DOUBLE, u.b );
}

void hb_retc( const char * szText )
{
    HB_SIZE n = 0;
    if( szText ) { while( szText[ n ] ) n++; }
    hb_retclen( szText, n );
}

/* --- byref stores (milestone 2.2) --- */

static HB_ULONG * stor_ptr( int i )
{
    const HB_ULONG * raw = cell_raw( i );
    if( ! raw || raw[ 0 ] != HBC_TAG_BYREF ) return (HB_ULONG *) 0;
    return (HB_ULONG *) raw[ 1 ];
}
static void stor_scalar( int i, HB_ULONG tag, HB_ULONG pay )
{
    /* Releases an old OWNED string payload before overwriting (a
     * Dyn-held array, tag 8, is left alone: arrays cross in 2.4). */
    HB_ULONG * w = stor_ptr( i );
    if( ! w ) return;
    if( w[ 0 ] == HBC_TAG_ARRAY || w[ 0 ] == HBC_TAG_SUBARR )
    {
        /* Overwriting a Dyn-held array through @ would orphan the block
         * (freeing it needs a recursive walk: tag-4 strings, tag-6
         * children). Fail closed instead (review v3, 2.4 named limit). */
        static const char msg[] = "hbc: hb_stor* over a @ byref holding an array is not in this increment (docs/EXTEND-BRIDGE.md)\n";
        sys_write_err( msg, sizeof( msg ) - 1 );
        sys_exit1();
    }
    if( w[ 0 ] == HBC_TAG_STR_OWN && w[ 1 ] ) hbc_freestr( (void *) w[ 1 ] );
    w[ 0 ] = tag; w[ 1 ] = pay;
}
int hb_storni( int iValue, int iParam )  { stor_scalar( iParam, HBC_TAG_INT, (HB_ULONG) (HB_LONG) iValue ); return stor_ptr( iParam ) != 0; }
int hb_stornl( HB_LONG lValue, int iParam ) { stor_scalar( iParam, HBC_TAG_INT, (HB_ULONG) lValue ); return stor_ptr( iParam ) != 0; }
int hb_stornd( double dValue, int iParam )
{
    union { double d; HB_ULONG b; } u;
    u.d = dValue;
    stor_scalar( iParam, HBC_TAG_DOUBLE, u.b );
    return stor_ptr( iParam ) != 0;
}
int hb_storl( int iLogical, int iParam ) { stor_scalar( iParam, HBC_TAG_LOGICAL, iLogical ? 1 : 0 ); return stor_ptr( iParam ) != 0; }
int hb_storclen( const char * szText, HB_SIZE nLength, int iParam )
{
    static const char empty = 0;
    void * owned;
    if( ! stor_ptr( iParam ) ) return 0;
    if( ! szText ) { szText = &empty; nLength = 0; }
    owned = hbc_strcpy( szText, nLength ); /* caller-owned layout, freed by the Dyn discipline */
    stor_scalar( iParam, HBC_TAG_STR_OWN, (HB_ULONG) owned );
    return 1;
}
int hb_storc( const char * szText, int iParam )
{
    HB_SIZE n = 0;
    if( szText ) { while( szText[ n ] ) n++; }
    return hb_storclen( szText, n, iParam );
}

/* --- opaque items (milestone 2.1) ---
 *
 * A PHB_ITEM is a pointer to two unsigned longs {tag, payload}, either
 * an argument casilla borrowed for the call (hb_param) or an owned item
 * (hb_itemNew). An owned item's header carries the mmap length one word
 * BEFORE the pointer, and its string payload (when any) is a separately
 * mmap'd buffer with its own length word before the bytes; both die in
 * hb_itemRelease. Putting a value on a borrowed argument casilla is not
 * supported in this slice (params are read-only through the item API);
 * hb_itemNew(param) makes a mutable copy. */

static void * item_alloc( HB_ULONG payload_len )
{
    /* [mmap total][tag][payload][payload bytes...] */
    HB_ULONG total = ( 24 + payload_len + 4095 ) & ~(HB_ULONG) 4095;
    void * base = sys_mmap( total );
    if( HBC_MAP_FAILED( base ) ) return (void *) 0;
    *(HB_ULONG *) base = total;
    return (char *) base + 8;
}

static void item_free( void * body )
{
    void * base = (char *) body - 8;
    sys_munmap( base, *(HB_ULONG *) base );
}

static HB_ULONG * item_words( PHB_ITEM p ) { return (HB_ULONG *) p; }

static HB_ULONG tag_to_type( HB_ULONG t, HB_ULONG pay )
{
    switch( t & HBC_TAG_MASK )
    {
        case HBC_TAG_INT:
        case HBC_TAG_INT_LIT:
            return ( (HB_LONG) pay >= -2147483648L && (HB_LONG) pay <= 2147483647L ) ? HB_IT_INTEGER : HB_IT_LONG;
        case HBC_TAG_DOUBLE:  return HB_IT_DOUBLE;
        case HBC_TAG_LOGICAL: return HB_IT_LOGICAL;
        case HBC_TAG_STR_BRW:
        case HBC_TAG_STR_OWN: return HB_IT_STRING;
        case HBC_TAG_SUBARR:
        case HBC_TAG_ARRAY:   return HB_IT_ARRAY;
        case HBC_TAG_BLOCK:   return HB_IT_BLOCK;
        default:              return HB_IT_NIL;
    }
}

/* Owned string payload layout: [mmap total(8)][byte len(8)][bytes...]
 * with the payload pointer at the bytes, so the hbc string convention
 * (byte length at payload-8) holds. item_free_str recovers the mmap
 * base two words back. */
static void item_free_str( void * p )
{
    void * base = (char *) p - 16;
    sys_munmap( base, *(HB_ULONG *) base );
}

static void item_clear_string( HB_ULONG * w )
{
    if( w[ 0 ] == HBC_TAG_STR_OWN && w[ 1 ] ) item_free_str( (void *) w[ 1 ] );
}

static void item_set_string( HB_ULONG * w, const char * s, HB_ULONG len )
{
    char * buf = (char *) item_alloc( 8 + len + 1 );
    HB_ULONG k;
    item_clear_string( w );
    if( ! buf ) { w[ 0 ] = HBC_TAG_NIL; w[ 1 ] = 0; return; }
    *(HB_ULONG *) buf = len;
    for( k = 0; k < len; k++ ) buf[ 8 + k ] = s ? s[ k ] : 0;
    buf[ 8 + len ] = 0;
    w[ 0 ] = HBC_TAG_STR_OWN;
    w[ 1 ] = (HB_ULONG) ( buf + 8 );
}

PHB_ITEM hb_itemNew( PHB_ITEM pNullOrSrc )
{
    HB_ULONG * w = (HB_ULONG *) item_alloc( 0 );
    if( ! w ) return (PHB_ITEM) 0;
    w[ 0 ] = HBC_TAG_NIL; w[ 1 ] = 0;
    if( pNullOrSrc )
    {
        HB_ULONG * s = item_words( pNullOrSrc );
        if( s[ 0 ] == HBC_TAG_STR_BRW || s[ 0 ] == HBC_TAG_STR_OWN )
        {
            const char * b = (const char *) s[ 1 ];
            item_set_string( w, b, ( (const HB_ULONG *) b )[ -1 ] );
        }
        else { w[ 0 ] = s[ 0 ]; w[ 1 ] = s[ 1 ]; }
    }
    return (PHB_ITEM) w;
}

HB_BOOL hb_itemRelease( PHB_ITEM pItem )
{
    HB_ULONG * w = (HB_ULONG *) pItem;
    if( ! w ) return 0;
    item_clear_string( w );
    item_free( w );
    return 1;
}

HB_TYPE hb_itemType( PHB_ITEM pItem )
{
    HB_ULONG * w = item_words( pItem );
    return w ? tag_to_type( w[ 0 ], w[ 1 ] ) : HB_IT_NIL;
}

int hb_itemGetNI( PHB_ITEM p ) { return (int) hb_itemGetNL( p ); }
HB_LONG hb_itemGetNL( PHB_ITEM p )
{
    HB_ULONG * w = item_words( p );
    if( ! w ) return 0;
    if( w[ 0 ] == HBC_TAG_INT || w[ 0 ] == HBC_TAG_INT_LIT ) return (HB_LONG) w[ 1 ];
    if( ( w[ 0 ] & HBC_TAG_MASK ) == HBC_TAG_DOUBLE ) { union { HB_ULONG b; double d; } u; u.b = w[ 1 ]; return (HB_LONG) u.d; }
    return 0;
}
double hb_itemGetND( PHB_ITEM p )
{
    HB_ULONG * w = item_words( p );
    if( ! w ) return 0.0;
    if( w[ 0 ] == HBC_TAG_INT || w[ 0 ] == HBC_TAG_INT_LIT ) return (double) (HB_LONG) w[ 1 ];
    if( ( w[ 0 ] & HBC_TAG_MASK ) == HBC_TAG_DOUBLE ) { union { HB_ULONG b; double d; } u; u.b = w[ 1 ]; return u.d; }
    return 0.0;
}
HB_BOOL hb_itemGetL( PHB_ITEM p )
{
    HB_ULONG * w = item_words( p );
    return w && w[ 0 ] == HBC_TAG_LOGICAL && w[ 1 ] != 0;
}
HB_SIZE hb_itemGetCLen( PHB_ITEM p )
{
    HB_ULONG * w = item_words( p );
    if( ! w || ( w[ 0 ] != HBC_TAG_STR_BRW && w[ 0 ] != HBC_TAG_STR_OWN ) ) return 0;
    return ( (HB_ULONG *) w[ 1 ] )[ -1 ];
}
char * hb_itemGetC( PHB_ITEM p )
{
    HB_SIZE n = hb_itemGetCLen( p );
    char * buf, * src;
    HB_ULONG k;
    HB_ULONG * w = item_words( p );
    /* Oracle-pinned (694428e): a non-string (NIL included) answers
     * NULL; an EMPTY string answers a non-NULL allocation. */
    if( ! w || ( w[ 0 ] != HBC_TAG_STR_BRW && w[ 0 ] != HBC_TAG_STR_OWN ) ) return (char *) 0;
    src = (char *) w[ 1 ];
    buf = (char *) item_alloc( n + 1 + 8 ); /* [total][bytes...] for hb_xfree */
    if( ! buf ) return (char *) 0;
    for( k = 0; k < n; k++ ) buf[ k ] = src[ k ];
    buf[ n ] = 0;
    return buf;
}
HB_SIZE hb_itemCopyC( PHB_ITEM p, char * szBuffer, HB_SIZE nLen )
{
    HB_SIZE n = hb_itemGetCLen( p );
    const char * src;
    /* Oracle-pinned (694428e): copies min(len, nLen) bytes WITHOUT a
     * terminator and returns the count copied. */
    if( ! n || ! szBuffer || ! nLen ) return 0;
    src = (const char *) item_words( p )[ 1 ];
    if( n > nLen ) n = nLen;
    { HB_SIZE k; for( k = 0; k < n; k++ ) szBuffer[ k ] = src[ k ]; }
    return n;
}
void hb_xfree( void * pMemory )
{
    if( pMemory ) item_free( pMemory );
}

PHB_ITEM hb_itemPutNI( PHB_ITEM p, int iNumber )  { HB_ULONG * w = item_words( p ); if( w ) { item_clear_string( w ); w[ 0 ] = HBC_TAG_INT; w[ 1 ] = (HB_ULONG) (HB_LONG) iNumber; } return p; }
PHB_ITEM hb_itemPutNL( PHB_ITEM p, HB_LONG lNumber ) { HB_ULONG * w = item_words( p ); if( w ) { item_clear_string( w ); w[ 0 ] = HBC_TAG_INT; w[ 1 ] = (HB_ULONG) lNumber; } return p; }
PHB_ITEM hb_itemPutND( PHB_ITEM p, double dNumber ) { HB_ULONG * w = item_words( p ); union { double d; HB_ULONG b; } u; if( w ) { item_clear_string( w ); u.d = dNumber; w[ 0 ] = HBC_TAG_DOUBLE; w[ 1 ] = u.b; } return p; }
PHB_ITEM hb_itemPutL( PHB_ITEM p, HB_BOOL bValue ){ HB_ULONG * w = item_words( p ); if( w ) { item_clear_string( w ); w[ 0 ] = HBC_TAG_LOGICAL; w[ 1 ] = bValue ? 1 : 0; } return p; }
PHB_ITEM hb_itemPutCL( PHB_ITEM p, const char * szText, HB_SIZE nLen )
{
    HB_ULONG * w = item_words( p );
    static const char empty = 0;
    if( ! w ) return p;
    if( ! szText ) { szText = &empty; nLen = 0; }
    item_set_string( w, szText, nLen );
    return p;
}
PHB_ITEM hb_itemPutC( PHB_ITEM p, const char * szText )
{
    HB_SIZE n = 0;
    if( szText ) { while( szText[ n ] ) n++; }
    return hb_itemPutCL( p, szText, n );
}

PHB_ITEM hb_itemReturn( PHB_ITEM pItem )
{
    /* Oracle-pinned (694428e): hb_itemReturn COPIES the value into the
     * return channel - the item KEEPS its value and hb_itemRelease
     * later frees it (no destructive NIL-izing, no leak). */
    HB_ULONG * w = item_words( pItem );
    if( ! w ) { hb_ret(); return (PHB_ITEM) 0; }
    switch( w[ 0 ] & HBC_TAG_MASK )
    {
        case HBC_TAG_INT:
        case HBC_TAG_INT_LIT:
        case HBC_TAG_DOUBLE:
        case HBC_TAG_LOGICAL:
            ret_set( w[ 0 ], w[ 1 ] );
            break;
        case HBC_TAG_STR_BRW:
        case HBC_TAG_STR_OWN: {
            const char * b = (const char *) w[ 1 ];
            ret_set( HBC_TAG_STR_OWN, (HB_ULONG) hbc_strcpy( b, ( (const HB_ULONG *) b )[ -1 ] ) );
            break;
        }
        default:
            ret_set( HBC_TAG_NIL, 0 );
    }
    return pItem;
}

/* Milestone 2.5: codeblocks across the bridge (the hb_eval* family,
 * hbapiitm.h:57-68 at 694428e). HB_EVALINFO is caller-allocated;
 * pItems[0] is the block, pItems[1..paramCount] the parameters.
 * Slice: INTEGER parameters only, the block's integer result comes
 * back as a new owned item; a NIL-returning block never reaches here
 * (compile-time named rejection on the .hb side). */

/* The block call runs through a STANDALONE asm trampoline with an
 * explicit ABI (SysV below: rdi=codeptr, rsi=values, rdx=count; the
 * Win64 variant maps the same three arguments from rcx/rdx/r8): the
 * parameters as 16-byte {value, meta} slots pushed left to right
 * (meta 0 - the checker pins integer parameters, whose meta word is
 * never read), result in %rax. The frame is rbp-anchored and restored
 * by address (lea -16(%rbp),%rsp on SysV, -24 for the three extra
 * saves on Win64, the alignment pad skipped), not by count arithmetic, so nothing the block
 * clobbers can unbalance the caller - and no compiler register
 * allocation can reinterpret the convention (review finding on the
 * inline-asm version). */
#ifndef _WIN32
__asm__(
    ".p2align 3\n"
    ".globl hbc_blk_launch\n"
    "hbc_blk_launch:\n"
    "    push %rbp\n"
    "    mov %rsp, %rbp\n"
    "    push %rbx\n"
    "    push %r12\n"
    "    mov %rdx, %rcx\n"
    "    mov %rdi, %rbx\n"
    "    test %rcx, %rcx\n"
    "    jz 2f\n"
    "1:\n"
    "    sub $16, %rsp\n"
    "    mov (%rsi), %rax\n"
    "    mov %rax, (%rsp)\n"
    "    movq $0, 8(%rsp)\n"
    "    add $8, %rsi\n"
    "    dec %rcx\n"
    "    jnz 1b\n"
    "2:\n"
    "    call *%rbx\n"
    "    lea -16(%rbp), %rsp\n"
    "    pop %r12\n"
    "    pop %rbx\n"
    "    pop %rbp\n"
    "    ret\n" );
#else /* _WIN32: same trampoline, Win64 argument registers */
/* rcx = codeptr, rdx = values, r8 = count. The C caller's rdi/rsi MUST
 * survive: Win64 treats them as callee-saved, but the called block is
 * hbc-generated code whose internal convention passes helper arguments
 * in rdi/rsi and clobbers them. rbx/rbp/r12-r15 are safe (hbc callees
 * preserve them on both targets), and the trampoline still saves the
 * rbx it borrows for the code pointer. The 8-byte pad keeps the same
 * rsp alignment at `call *%rbx` the SysV version has. */
__asm__(
    ".p2align 3\n"
    ".globl hbc_blk_launch\n"
    "hbc_blk_launch:\n"
    "    push %rbp\n"
    "    mov %rsp, %rbp\n"
    "    push %rbx\n"
    "    push %rdi\n"
    "    push %rsi\n"
    "    sub $8, %rsp\n"
    "    mov %rcx, %rbx\n"
    "    mov %rdx, %rsi\n"
    "    mov %r8, %rdi\n"
    "    test %rdi, %rdi\n"
    "    jz 2f\n"
    "1:\n"
    "    sub $16, %rsp\n"
    "    mov (%rsi), %rax\n"
    "    mov %rax, (%rsp)\n"
    "    movq $0, 8(%rsp)\n"
    "    add $8, %rsi\n"
    "    dec %rdi\n"
    "    jnz 1b\n"
    "2:\n"
    "    call *%rbx\n"
    "    lea -24(%rbp), %rsp\n"   /* skip the alignment pad: pops start at the saved rsi */
    "    pop %rsi\n"
    "    pop %rdi\n"
    "    pop %rbx\n"
    "    pop %rbp\n"
    "    ret\n" );
#endif
extern HB_LONG hbc_blk_launch( HB_LONG codeptr, const HB_ULONG * vals, HB_LONG count );

HB_BOOL hb_evalNew( PHB_EVALINFO pEvalInfo, PHB_ITEM pItem )
{
    HB_ULONG * w;
    if( ! pEvalInfo || ! pItem ) return 0;
    w = item_words( pItem );
    if( ! w || w[ 0 ] != HBC_TAG_BLOCK ) return 0;
    pEvalInfo->paramCount = 0;
    pEvalInfo->pItems[ 0 ] = pItem;
    return 1;
}

HB_BOOL hb_evalPutParam( PHB_EVALINFO pEvalInfo, PHB_ITEM pItem )
{
    HB_ULONG * w;
    if( ! pEvalInfo || ! pItem ) return 0;
    if( pEvalInfo->paramCount >= HB_EVAL_PARAM_MAX_ ) return 0; /* frame full */
    w = item_words( pItem );
    if( ! w || ( w[ 0 ] != HBC_TAG_INT && w[ 0 ] != HBC_TAG_INT_LIT ) )
    {
        /* Named rejection (2.5 slice): the block ABI reads raw i64
         * slots, so only INTEGER parameters cross. */
        static const char msg[] = "hbc: hb_evalPutParam accepts only INTEGER parameters in this increment (docs/EXTEND-BRIDGE.md)\n";
        sys_write_err( msg, sizeof( msg ) - 1 );
        sys_exit1();
    }
    pEvalInfo->pItems[ ++pEvalInfo->paramCount ] = pItem;
    return 1;
}

PHB_ITEM hb_evalLaunch( PHB_EVALINFO pEvalInfo )
{
    HB_ULONG vals[ HB_EVAL_PARAM_MAX_ ];
    HB_LONG codeptr, ret;
    int i, n;
    if( ! pEvalInfo || ! pEvalInfo->pItems[ 0 ] ) return (PHB_ITEM) 0;
    codeptr = (HB_LONG) item_words( pEvalInfo->pItems[ 0 ] )[ 1 ];
    n = pEvalInfo->paramCount;
    for( i = 0; i < n; i++ )
        vals[ i ] = item_words( pEvalInfo->pItems[ i + 1 ] )[ 1 ];
    ret = hbc_blk_launch( codeptr, vals, n );
    return hb_itemPutNL( hb_itemNew( (PHB_ITEM) 0 ), ret );
}

HB_BOOL hb_evalRelease( PHB_EVALINFO pEvalInfo )
{
    int i;
    if( ! pEvalInfo ) return 0;
    /* evalNew / successful PutParam transfer owned items to this frame.
     * hb_param handles remain borrowed from the active C call, including
     * the single byref hop performed by cell_ptr. Never unmap those slots. */
    for( i = 0; i <= pEvalInfo->paramCount; i++ )
    {
        PHB_ITEM p = pEvalInfo->pItems[ i ];
        int arg, borrowed = 0;
        if( ! p ) continue;
        for( arg = 1; arg <= hb_pcount(); arg++ )
            if( p == (PHB_ITEM) cell_ptr( arg ) ) { borrowed = 1; break; }
        if( ! borrowed ) hb_itemRelease( p );
    }
    pEvalInfo->paramCount = 0;
    for( i = 0; i <= HB_EVAL_PARAM_MAX_; i++ ) pEvalInfo->pItems[ i ] = (PHB_ITEM) 0;
    return 1;
}

/* Sentinel so the hbhbr_funcs section (and the __start_/__stop_ bounds
 * the dispatcher walks) exists even when no other object registers a
 * function; the empty name never matches a real call. */
__attribute__( ( used, section( "hbhbr_funcs" ), aligned( 8 ) ) )
static const HBC_EXT_ENTRY hbc_ext_sentinel = { "", (HBC_EXT_FN) 0 };
