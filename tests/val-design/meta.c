#include "hbapi.h"
#include "hbapiitm.h"
#include <stdint.h>
#include <stdio.h>
#include <string.h>
/* Oracle observation only. No compiler/runtime implementation is copied. */
HB_FUNC( NUMMETA )
{
 PHB_ITEM p=hb_param(1,HB_IT_NUMERIC);
 int width=0,dec=0;
 PHB_ITEM a=hb_itemArrayNew(4);
 if(p) hb_itemGetNLen(p,&width,&dec);
 hb_arraySetC(a,1,!p?"NONNUM":HB_IS_DOUBLE(p)?"F64":HB_IS_NUMINT(p)?"INT":"OTHER");
 hb_arraySetNI(a,2,width);
 hb_arraySetNI(a,3,dec);
 if(p) {
  char payload[64];
  if(HB_IS_DOUBLE(p)) { double d=hb_itemGetND(p);uint64_t bits;memcpy(&bits,&d,8);snprintf(payload,sizeof(payload),"%016llx",(unsigned long long)bits); }
  else snprintf(payload,sizeof(payload),"%lld",(long long)hb_itemGetNInt(p));
  hb_arraySetC(a,4,payload);
 }
 hb_itemReturnRelease(a);
}
