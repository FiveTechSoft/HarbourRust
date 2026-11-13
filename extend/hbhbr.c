/* hbhbr.c - HarbourRust Extend-System bridge runtime, milestone 1.
 *
 * HarbourRust's OWN implementation (MIT); no Harbour code. Freestanding:
 * no libc, allocations through raw Linux syscalls, so the object links
 * into the hbc no-libc flow (ld or hbmk2 -nostdlib). See
 * docs/EXTEND-BRIDGE.md for the contract and the current limits.
 *
 * Build: gcc -c -O2 -ffreestanding -fno-stack-protector hbhbr.c -o hbhbr.o
 */

#include "hbhbr.h"

/* Provided by the hbc-generated object (exported when EXTERNAL is used):
 * hbc_strcpy(src, len) -> owned buffer copy with its length word at
 * data-8 (the hbc owned-string layout); hbc_freestr(ptr) releases it. */
extern void * hbc_strcpy( const void * src, unsigned long len );
extern void   hbc_freestr( void * owned );

/* Bridge state, written by hbc_ext_dispatch before every call.
 * hbc_ext_argv points at 16-byte {tag,payload} casillas pushed left to
 * right; argument i (1-based) sits at index 2*(argc-i) / +1. */
unsigned long        hbc_ext_argc;
const unsigned long *hbc_ext_argv;
unsigned long        hbc_ext_ret_tag = 1; /* NIL */
unsigned long        hbc_ext_ret_pay = 0;

/* hbc Dyn tags: 0/9 integer, 1 NIL, 2 borrowed string, 3 logical,
 * 4 owned string. String payload -> bytes; length word at payload-8. */
#define HBC_TAG_INT     0
#define HBC_TAG_NIL     1
#define HBC_TAG_STR_BRW 2
#define HBC_TAG_LOGICAL 3
#define HBC_TAG_STR_OWN 4
#define HBC_TAG_INT_LIT 9

static unsigned long cell_tag( int i )
{
    if( i < 1 || (unsigned long) i > hbc_ext_argc ) return HBC_TAG_NIL;
    return hbc_ext_argv[ 2 * ( hbc_ext_argc - (unsigned long) i ) ];
}
static unsigned long cell_pay( int i )
{
    if( i < 1 || (unsigned long) i > hbc_ext_argc ) return 0;
    return hbc_ext_argv[ 2 * ( hbc_ext_argc - (unsigned long) i ) + 1 ];
}

int hb_pcount( void ) { return (int) hbc_ext_argc; }

HB_ULONG hb_parinfo( int iParam )
{
    if( iParam == 0 ) return hbc_ext_argc; /* Harbour: param count */
    switch( cell_tag( iParam ) )
    {
        case HBC_TAG_INT:
        case HBC_TAG_INT_LIT: {
            /* Harbour oracle: a whole number inside the 32-bit range is
             * HB_IT_INTEGER (42 -> 2), beyond it HB_IT_LONG
             * (2147483648 -> 8). */
            long v = (long) cell_pay( iParam );
            return ( v >= -2147483648L && v <= 2147483647L ) ? HB_IT_INTEGER : HB_IT_LONG;
        }
        case HBC_TAG_LOGICAL: return HB_IT_LOGICAL;
        case HBC_TAG_STR_BRW:
        case HBC_TAG_STR_OWN: return HB_IT_STRING;
        default:              return HB_IT_NIL;
    }
}

int hb_extIsNil( int iParam ) { return cell_tag( iParam ) == HBC_TAG_NIL; }

const void * hb_param( int iParam, HB_ULONG mask )
{
    /* Harbour oracle: an argument PRESENT with value NIL answers
     * non-NULL for HB_IT_ANY; an OMITTED argument answers NULL. */
    if( iParam < 1 || (unsigned long) iParam > hbc_ext_argc ) return (const void *) 0;
    if( cell_tag( iParam ) == HBC_TAG_NIL )
        return mask == HB_IT_ANY ? (const void *) 1 : (const void *) 0;
    return ( hb_parinfo( iParam ) & mask ) ? (const void *) 1 : (const void *) 0;
}

long hb_parnl( int iParam )
{
    unsigned long t = cell_tag( iParam );
    if( t == HBC_TAG_INT || t == HBC_TAG_INT_LIT ) return (long) cell_pay( iParam );
    return 0; /* Harbour answers 0 on a type mismatch at this API level */
}
int hb_parni( int iParam ) { return (int) hb_parnl( iParam ); }

int hb_parl( int iParam )
{
    return cell_tag( iParam ) == HBC_TAG_LOGICAL && cell_pay( iParam ) != 0;
}

/* --- scratch copies (hb_parc), freed by hbc_ext_end after the call --- */

static void * sys_mmap( unsigned long len )
{
    void * ret;
    register long r10 __asm__( "r10" ) = 0x22; /* MAP_PRIVATE|MAP_ANONYMOUS */
    register long r8  __asm__( "r8" )  = -1;
    register long r9  __asm__( "r9" )  = 0;
    __asm__ volatile( "syscall"
        : "=a"( ret )
        : "a"( 9L ), "D"( 0L ), "S"( len ), "d"( 3L ), "r"( r10 ), "r"( r8 ), "r"( r9 )
        : "rcx", "r11", "memory" );
    return ret;
}
static void sys_munmap( void * addr, unsigned long len )
{
    register long rsi __asm__( "rsi" ) = (long) len;
    __asm__ volatile( "syscall"
        : /* no output */
        : "a"( 11L ), "D"( addr ), "r"( rsi )
        : "rcx", "r11", "memory" );
}

#define HBC_EXT_SCRATCH_MAX 256
static void * scratch[ HBC_EXT_SCRATCH_MAX ];
static int    scratch_n;

static void * scratch_alloc( unsigned long len )
{
    /* 8-byte header holds the mmap length so scratch_free needs nothing
     * else; the returned pointer is the byte after the header. */
    unsigned long total = ( len + 8 + 4095 ) & ~4095UL;
    void * base;
    if( scratch_n >= HBC_EXT_SCRATCH_MAX ) return (void *) 0;
    base = sys_mmap( total );
    if( (unsigned long) base > (unsigned long) -4096 ) return (void *) 0;
    *(unsigned long *) base = total;
    scratch[ scratch_n++ ] = base;
    return (char *) base + 8;
}

/* Called by hbc_ext_dispatch after the C function returns. */
void hbc_ext_end( void )
{
    while( scratch_n > 0 )
    {
        void * base = scratch[ --scratch_n ];
        sys_munmap( base, *(unsigned long *) base );
    }
}

const char * hb_parc( int iParam )
{
    unsigned long t = cell_tag( iParam );
    const char * src;
    char * buf;
    unsigned long len, k;
    if( t != HBC_TAG_STR_BRW && t != HBC_TAG_STR_OWN ) return (const char *) 0; /* Harbour: NULL */
    src = (const char *) cell_pay( iParam );
    len = ( (const unsigned long *) src )[ -1 ];
    buf = (char *) scratch_alloc( len + 1 );
    if( ! buf ) return "";
    for( k = 0; k < len; k++ ) buf[ k ] = src[ k ];
    buf[ len ] = 0;
    return buf;
}

HB_SIZE hb_parclen( int iParam )
{
    unsigned long t = cell_tag( iParam );
    if( t != HBC_TAG_STR_BRW && t != HBC_TAG_STR_OWN ) return 0;
    return ( (const unsigned long *) cell_pay( iParam ) )[ -1 ];
}

/* --- return value --- */

void hb_ret( void ) { hbc_ext_ret_tag = HBC_TAG_NIL; hbc_ext_ret_pay = 0; }

void hb_retl( int iTrueFalse )
{
    hbc_ext_ret_tag = HBC_TAG_LOGICAL;
    hbc_ext_ret_pay = iTrueFalse ? 1 : 0;
}
void hb_retni( int iNumber )
{
    hbc_ext_ret_tag = HBC_TAG_INT;
    hbc_ext_ret_pay = (unsigned long) (long) iNumber;
}
void hb_retnl( long lNumber )
{
    hbc_ext_ret_tag = HBC_TAG_INT;
    hbc_ext_ret_pay = (unsigned long) lNumber;
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
    hbc_ext_ret_tag = HBC_TAG_STR_OWN;
    hbc_ext_ret_pay = (unsigned long) owned;
}
void hb_retc( const char * szText )
{
    HB_SIZE n = 0;
    if( szText ) { while( szText[ n ] ) n++; }
    hb_retclen( szText, n );
}

/* Sentinel so the hbhbr_funcs section (and the __start_/__stop_ bounds
 * the dispatcher walks) exists even when no other object registers a
 * function; the empty name never matches a real call. */
__attribute__( ( used, section( "hbhbr_funcs" ), aligned( 8 ) ) )
static const HBC_EXT_ENTRY hbc_ext_sentinel = { "", (HBC_EXT_FN) 0 };
