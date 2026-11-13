/* myext.c - milestone-1 demo extension for the HarbourRust Extend
 * bridge. Ordinary C, compiled with a standard C compiler; the only
 * contract is hbhbr.h. */
#include "hbhbr.h"

HB_FUNC( HBR_ADD )
{
    /* omitted arguments read NIL; hb_parni(NIL) is 0, like Harbour */
    hb_retnl( (long) hb_parni( 1 ) + (long) hb_parni( 2 ) );
}

HB_FUNC( HBR_SHOUT )
{
    /* hb_parc: NUL-terminated copy valid until this function returns */
    const char * s = hb_parc( 1 );
    char buf[ 256 ];
    int i = 0;
    for( ; s[ i ] && i < 255; i++ )
    {
        char c = s[ i ];
        buf[ i ] = ( c >= 'a' && c <= 'z' ) ? c - 32 : c;
    }
    buf[ i ] = 0;
    hb_retc( buf ); /* copied out; ownership passes to the caller */
}

HB_FUNC( HBR_DESCRIBE )
{
    /* hb_pcount + type tests; builds "N:int,2:str,3:log" style text */
    char buf[ 256 ];
    int n = hb_pcount();
    int i, p = 0;
    for( i = 1; i <= n && p < 240; i++ )
    {
        const char * t = HB_ISCHAR( i ) ? "str" : HB_ISLOG( i ) ? "log" :
                         HB_ISNUM( i ) ? "num" : "nil";
        const char * q = t;
        if( i > 1 ) buf[ p++ ] = ',';
        while( *q && p < 250 ) buf[ p++ ] = *q++;
    }
    buf[ p ] = 0;
    hb_retc( buf );
}
