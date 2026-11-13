/* hbhbr.h - HarbourRust Extend-System bridge, milestone 1 (Linux).
 *
 * HarbourRust's OWN implementation (MIT), API-compatible with the C
 * Extend System subset below. No Harbour code is copied or translated;
 * Harbour is only the behavioural reference. See docs/EXTEND-BRIDGE.md.
 *
 * Usage: compile your extension with any standard C compiler
 *   gcc -c -O2 -I<repo>/extend myext.c -o myext.o
 * and link it with the hbc-generated object and hbhbr.o:
 *   ld -o app app.o myext.o hbhbr.o        (or via hbmk2, see the doc)
 *
 * A C extension function is declared with HB_FUNC(NAME) and reads its
 * parameters with the hb_par family and answers with the hb_ret
 * family. On the Harbour side the function is declared EXTERNAL NAME.
 */
#ifndef HBHBR_H
#define HBHBR_H

#ifdef __cplusplus
extern "C" {
#endif

typedef long          HB_LONG;
typedef unsigned long HB_ULONG;
typedef unsigned long HB_SIZE;
typedef int           HB_BOOL;

/* Item types: the same values Harbour's hbapi.h assigns, so code using
 * the HB_IT_* constants behaves identically. */
#define HB_IT_NIL       0x00000
#define HB_IT_POINTER   0x00001
#define HB_IT_INTEGER   0x00002
#define HB_IT_HASH      0x00004
#define HB_IT_LONG      0x00008
#define HB_IT_DOUBLE    0x00010
#define HB_IT_DATE      0x00020
#define HB_IT_LOGICAL   0x00080
#define HB_IT_SYMBOL    0x00100
#define HB_IT_STRING    0x00400
#define HB_IT_MEMOFLAG  0x00800
#define HB_IT_MEMO      ( HB_IT_MEMOFLAG | HB_IT_STRING )
#define HB_IT_BLOCK     0x01000
#define HB_IT_BYREF     0x02000
#define HB_IT_ARRAY     0x08000
#define HB_IT_NUMERIC   ( HB_IT_INTEGER | HB_IT_LONG | HB_IT_DOUBLE )
#define HB_IT_ANY       0xFFFFFFFF

/* Registration: one entry per HB_FUNC in the hbhbr_funcs linker
 * section; hbc_ext_dispatch walks it at call time. Function names are
 * matched case-insensitively (Harbour names are case-insensitive). */
typedef void (* HBC_EXT_FN )( void );
typedef struct { const char * name; HBC_EXT_FN fn; } HBC_EXT_ENTRY;

#define HB_FUNC( NAME ) \
    static void HBC_FN_##NAME( void ); \
    __attribute__( ( used, section( "hbhbr_funcs" ), aligned( 8 ) ) ) \
    static const HBC_EXT_ENTRY HBC_REG_##NAME = { #NAME, HBC_FN_##NAME }; \
    static void HBC_FN_##NAME( void )

/* Parameter access. iParam is 1-based; an index beyond hb_pcount()
 * reads NIL, like Harbour. */
int           hb_pcount( void );
HB_ULONG      hb_parinfo( int iParam );          /* hb_parinfo(0) = param count */
int           hb_extIsNil( int iParam );
const void *  hb_param( int iParam, HB_ULONG mask ); /* non-NULL when the type matches */
int           hb_parni( int iParam );
long          hb_parnl( int iParam );
int           hb_parl( int iParam );
const char *  hb_parc( int iParam );   /* NUL-terminated scratch copy, valid until this C function returns */
HB_SIZE       hb_parclen( int iParam );          /* byte length (NUL-safe access with hb_parc) */

/* Return value. Exactly one hb_ret* per logical return; the default is
 * NIL (a function that returns nothing answers NIL, like Harbour). */
void hb_ret( void );                      /* NIL */
void hb_retl( int iTrueFalse );
void hb_retni( int iNumber );
void hb_retnl( long lNumber );
void hb_retc( const char * szText );                    /* C string, copied */
void hb_retclen( const char * szText, HB_SIZE nLen );   /* counted bytes, copied */

/* Type-test macros, same spellings as Harbour. */
#define HB_ISNIL( n )  ( hb_extIsNil( n ) )
#define HB_ISCHAR( n ) ( hb_param( n, HB_IT_STRING ) != 0 )
#define HB_ISNUM( n )  ( hb_param( n, HB_IT_NUMERIC ) != 0 )
#define HB_ISLOG( n )  ( hb_param( n, HB_IT_LOGICAL ) != 0 )

#ifdef __cplusplus
}
#endif

#endif /* HBHBR_H */
