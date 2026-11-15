#include "hbapi.h"
#include "hbapiitm.h"
#include <stdio.h>
#include <string.h>
#include <stdint.h>
/* Observe conversion without asking Space to allocate huge strings. */
HB_FUNC( COUNTMETA ) {
 PHB_ITEM v=hb_param(1,HB_IT_NUMERIC);char text[80];
 snprintf(text,sizeof(text),"%lld",(long long)hb_itemGetNS(v));hb_retc(text);
}
HB_FUNC( SPECIAL ) {
 uint64_t bits=(uint64_t)hb_parnint(1);double d;
 if(bits==1)bits=UINT64_C(0x7ff0000000000000);
 else if(bits==2)bits=UINT64_C(0xfff0000000000000);
 else bits=UINT64_C(0x7ff8000000000000);
 memcpy(&d,&bits,8);hb_retnd(d);
}
HB_FUNC( FROMHEX ) {
 const char *p=hb_parc(1); uint64_t bits=0;double d;
 sscanf(p,"%llx",(unsigned long long*)&bits);memcpy(&d,&bits,8);hb_retnd(d);
}
