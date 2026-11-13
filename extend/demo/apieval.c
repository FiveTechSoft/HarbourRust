#include "hbhbr.h"
HB_FUNC( HBR_EVAL )
{
    HB_EVALINFO info;
    PHB_ITEM p1, p2, r;
    long v;
    if( ! hb_evalNew( &info, hb_param( 1, HB_IT_BLOCK ) ) ) { hb_retni( -1 ); return; }
    p1 = hb_itemPutNL( hb_itemNew( (PHB_ITEM) 0 ), 6 );
    p2 = hb_itemPutNL( hb_itemNew( (PHB_ITEM) 0 ), 7 );
    hb_evalPutParam( &info, p1 );
    hb_evalPutParam( &info, p2 );
    r = hb_evalLaunch( &info );
    v = r ? hb_itemGetNL( r ) : -2;
    hb_retnl( v );
    hb_itemRelease( r );
    hb_evalRelease( &info );
}
HB_FUNC( HBR_BINFO ) { hb_retnl( hb_parinfo( 1 ) ); }
HB_FUNC( HBR_ISBQ )  { hb_retl( HB_ISBLOCK( 1 ) ); }
