#include "hbhbr.h"
HB_FUNC( HBR_EVALBAD )
{
    HB_EVALINFO info;
    if( ! hb_evalNew( &info, hb_param( 1, HB_IT_BLOCK ) ) ) { hb_retni( -1 ); return; }
    hb_evalPutParam( &info, hb_itemPutC( hb_itemNew( (PHB_ITEM) 0 ), "nope" ) );
    hb_retni( 0 );
}
