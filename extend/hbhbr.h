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
typedef unsigned int  HB_U32;
typedef HB_U32        HB_TYPE;   /* Harbour hbdefs.h: typedef HB_U32 HB_TYPE */
typedef unsigned short HB_USHORT;   /* hbdefs.h:460 */

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

/* H2.0 binding: the function IS the global symbol HBHBR_FN_<NAME>,
 * called directly by the hbc thunk (a missing function is a link
 * error). The hbhbr_funcs section entry stays so objects built with a
 * pre-2.0 hbc (section-walk dispatcher) keep working. Harbour names
 * are uppercase by convention; hbc uppercases the EXTERNAL name when
 * forming the symbol. */
#define HB_FUNC( NAME ) \
    void HBHBR_FN_##NAME( void ); \
    __attribute__( ( used, section( "hbhbr_funcs" ), aligned( 8 ) ) ) \
    static const HBC_EXT_ENTRY HBC_REG_##NAME = { #NAME, HBHBR_FN_##NAME }; \
    void HBHBR_FN_##NAME( void )

/* Opaque item handle. A PHB_ITEM from hb_itemNew is owned by the
 * extension and released with hb_itemRelease; hb_param with a matching
 * mask returns a READ-ONLY handle to the argument itself (valid until
 * the C function returns - hb_itemNew() it to keep one). */
typedef void *      PHB_ITEM;

/* Parameter access. iParam is 1-based; an index beyond hb_pcount()
 * reads NIL, like Harbour. */
int           hb_pcount( void );
HB_ULONG      hb_parinfo( int iParam );          /* hb_parinfo(0) = param count */
int           hb_extIsNil( int iParam );         /* HarbourRust extension (no Harbour twin) */
PHB_ITEM      hb_param( int iParam, long lMask ); /* non-NULL when the type matches (Harbour hbapi.h:630) */
int           hb_parni( int iParam );
long          hb_parnl( int iParam );
double        hb_parnd( int iParam );
int           hb_parl( int iParam );
const char *  hb_parc( int iParam );   /* NUL-terminated scratch copy, valid until this C function returns */
HB_SIZE       hb_parclen( int iParam );          /* byte length (NUL-safe access with hb_parc) */

/* Return value. Exactly one hb_ret* per logical return; the default is
 * NIL (a function that returns nothing answers NIL, like Harbour). */
void hb_ret( void );                      /* NIL */
void hb_retl( int iTrueFalse );
void hb_retni( int iNumber );
void hb_retnl( long lNumber );
void hb_retnd( double dNumber );
void hb_retc( const char * szText );                    /* C string, copied */
void hb_retclen( const char * szText, HB_SIZE nLen );   /* counted bytes, copied */

/* Item API (milestone 2.1), names and signatures aligned with
 * Harbour's hbapiitm.h @694428e (line cited per function).
 * hb_itemGetC's copy is released with hb_xfree, like Harbour. */
PHB_ITEM      hb_itemNew( PHB_ITEM pNull );      /* :106 - NULL -> NIL item; else deep copy */
HB_BOOL       hb_itemRelease( PHB_ITEM pItem );  /* :140 */
HB_TYPE       hb_itemType( PHB_ITEM pItem );     /* :145 */
int           hb_itemGetNI( PHB_ITEM pItem );    /* :98 */
long          hb_itemGetNL( PHB_ITEM pItem );    /* :99 */
double        hb_itemGetND( PHB_ITEM pItem );    /* :96 */
HB_BOOL       hb_itemGetL( PHB_ITEM pItem );     /* :94 */
char *        hb_itemGetC( PHB_ITEM pItem );     /* :86 - fresh copy: hb_xfree it */
HB_SIZE       hb_itemGetCLen( PHB_ITEM pItem );  /* :88 - byte length, 0 if not a string */
HB_SIZE       hb_itemCopyC( PHB_ITEM pItem, char * szBuffer, HB_SIZE nLen ); /* :82 */
void          hb_xfree( void * pMemory );        /* hbapi.h:490 */
PHB_ITEM      hb_itemPutNI( PHB_ITEM pItem, int iNumber );        /* :125 */
PHB_ITEM      hb_itemPutNL( PHB_ITEM pItem, long lNumber );       /* :126 */
PHB_ITEM      hb_itemPutND( PHB_ITEM pItem, double dNumber );     /* :124 */
PHB_ITEM      hb_itemPutL( PHB_ITEM pItem, HB_BOOL bValue );      /* :123 */
PHB_ITEM      hb_itemPutC( PHB_ITEM pItem, const char * szText ); /* :110 */
PHB_ITEM      hb_itemPutCL( PHB_ITEM pItem, const char * szText, HB_SIZE nLen ); /* :111 */
PHB_ITEM      hb_itemReturn( PHB_ITEM pItem );   /* :141 - COPIES the value: the item keeps it; caller still releases */

/* Arrays, read-only (milestone 2.4). A Dyn-held array crosses as its
 * borrowed casilla; hb_itemType / hb_parinfo report HB_IT_ARRAY ("A").
 * The canonical Harbour pattern works unchanged: a = hb_param(i,
 * HB_IT_ARRAY), then hb_arrayLen(a) (0 on non-arrays, empty arrays and
 * NULL) and hb_arrayGet* / hb_arrayGetItemPtr(a, n) for elements -
 * NULL on an out-of-range index. Element handles are borrowed and
 * READ-ONLY (valid until the C function returns): mutation, resize,
 * hb_itemNew of an array and array return values are not in this
 * increment. The hb_array* functions read through ONE byref hop (an
 * @array argument), so the canonical pattern works on @a too - a
 * HarbourRust extension over the 2.2 marker contract (hb_param on a
 * BYREF argument itself returns the marker casilla, the 2.2 named
 * limit). */
HB_SIZE       hb_arrayLen( PHB_ITEM pArray );    /* hbapi.h:795 */
PHB_ITEM      hb_arrayGetItemPtr( PHB_ITEM pArray, HB_SIZE nIndex ); /* :809 */
HB_SIZE       hb_parinfa( int iParamNum, HB_SIZE nArrayIndex ); /* :629 - 0: length; n: element type */
HB_TYPE       hb_arrayGetType( PHB_ITEM pArray, HB_SIZE nIndex );    /* :827 */
int           hb_arrayGetNI( PHB_ITEM pArray, HB_SIZE nIndex );      /* :818 */
long          hb_arrayGetNL( PHB_ITEM pArray, HB_SIZE nIndex );      /* :819 */
double        hb_arrayGetND( PHB_ITEM pArray, HB_SIZE nIndex );      /* :822 */
HB_BOOL       hb_arrayGetL( PHB_ITEM pArray, HB_SIZE nIndex );       /* :817 */
char *        hb_arrayGetC( PHB_ITEM pArray, HB_SIZE nIndex );       /* :811 - fresh copy: hb_xfree it */
HB_SIZE       hb_arrayGetCLen( PHB_ITEM pArray, HB_SIZE nIndex );    /* :813 */

/* Codeblocks across the bridge (milestone 2.5). An integer-result
 * codeblock crosses as a tag-7 casilla; hb_itemType / hb_parinfo
 * report HB_IT_BLOCK ("B"). The hb_eval* family mirrors the pinned
 * header exactly: HB_EVALINFO is a CALLER-ALLOCATED struct
 * (hbapiitm.h:57-63), not an opaque pointer. Slice limits
 * (docs/EXTEND-BRIDGE.md): parameters must be INTEGER items
 * (hb_evalPutParam over anything else is a named rejection), a
 * NIL-returning block never crosses (compile-time named rejection on
 * the .hb side), and the 10th parameter fills the frame -
 * hb_evalPutParam returns HB_FALSE there. */
#define HB_EVAL_PARAM_MAX_ 9                                /* hbapiitm.h:57 */
typedef struct
{
    HB_USHORT paramCount;                                   /* :61 */
    PHB_ITEM  pItems[ HB_EVAL_PARAM_MAX_ + 1 ];             /* :62 */
} HB_EVALINFO, * PHB_EVALINFO;                              /* :63 */
PHB_ITEM      hb_evalLaunch( PHB_EVALINFO pEvalInfo );      /* :65 - integer result as a new owned item */
HB_BOOL       hb_evalNew( PHB_EVALINFO pEvalInfo, PHB_ITEM pItem );      /* :66 */
HB_BOOL       hb_evalPutParam( PHB_EVALINFO pEvalInfo, PHB_ITEM pItem ); /* :67 */
HB_BOOL       hb_evalRelease( PHB_EVALINFO pEvalInfo );     /* :68 */

/* By reference (milestone 2.2): `@x` on the Harbour side passes the
 * address of x's Dyn casilla. hb_par* read through it; hb_parinfo ORs
 * HB_IT_BYREF over the referred type; the hb_stor* family writes the
 * caller's value through it (a no-op when the argument is not byref). */
/* Harbour has no hb_parbyref: test byref with HB_ISBYREF (below), as
 * real extension code does. */
int hb_storc( const char * szText, int iParam );                    /* hbapi.h:755 */
int hb_storclen( const char * szText, HB_SIZE nLength, int iParam );/* :756 */
int hb_storl( int iLogical, int iParam );                           /* :762 */
int hb_storni( int iValue, int iParam );                            /* :763 */
int hb_stornl( long lValue, int iParam );                           /* :764 */
int hb_stornd( double dValue, int iParam );                         /* :766 */

/* Type-test macros, same spellings as Harbour. */
#define HB_ISNIL( n )  ( hb_extIsNil( n ) )
#define HB_ISCHAR( n ) ( hb_param( n, HB_IT_STRING ) != 0 )
#define HB_ISNUM( n )  ( hb_param( n, HB_IT_NUMERIC ) != 0 )
#define HB_ISLOG( n )  ( hb_param( n, HB_IT_LOGICAL ) != 0 )
#define HB_ISBYREF( n )  ( ( hb_parinfo( n ) & HB_IT_BYREF ) != 0 )   /* hbapi.h:232 */
#define HB_ISARRAY( n )  ( hb_param( n, HB_IT_ARRAY ) != 0 )          /* :233 */
#define HB_ISBLOCK( n )  ( hb_param( n, HB_IT_BLOCK ) != 0 )          /* :235 */

#ifdef __cplusplus
}
#endif

#endif /* HBHBR_H */
