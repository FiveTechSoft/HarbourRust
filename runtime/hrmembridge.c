/* Internal native-C ownership bridge, no parser or evaluator dependency. */
#include "hrmembridge.h"
#include "hrdyn.h"
static int valid(const hrmb_context*c){return c&&c->string_copy&&c->float_new;}
hrmv_status hrmb_init(hrmb_context*c,hrmv_alloc_fn a,hrmv_free_fn f,void*raw,hrmb_string_fn s,hrmb_float_fn d,void*compiler){
 hrmv_status rc;if(!c||!s||!d)return HRMV_BAD_ARGUMENT;
 rc=hrmv_init(&c->storage,a,f,raw);if(rc!=HRMV_OK)return rc;
 c->compiler_user=compiler;c->string_copy=s;c->float_new=d;return HRMV_OK;
}
void hrmb_destroy(hrmb_context*c){if(c)hrmv_destroy(&c->storage);}
hrmv_status hrmb_frame_enter(hrmb_context*c,uint64_t*m){return valid(c)?hrmv_frame_enter(&c->storage,m):HRMV_BAD_ARGUMENT;}
hrmv_status hrmb_frame_leave(hrmb_context*c,uint64_t m){return valid(c)?hrmv_frame_leave(&c->storage,m):HRMV_BAD_ARGUMENT;}
hrmv_status hrmb_declare(hrmb_context*c,int priv,const char*n,size_t len){
 if(!valid(c)||(priv!=0&&priv!=1))return HRMV_BAD_ARGUMENT;
 return priv?hrmv_declare_private(&c->storage,n,len):hrmv_declare_public(&c->storage,n,len);
}
/* Two explicit operations: successful declaration survives a failed put as
 * its default NIL/.F. value. Existing binding put remains transactional.
 * No declaration rollback is implied. */
hrmv_status hrmb_declare_put(hrmb_context*c,int priv,const char*n,size_t len,hrv_cell input){
 hrmv_status rc=hrmb_declare(c,priv,n,len);if(rc!=HRMV_OK)return rc;
 return hrmv_put_copy(&c->storage,n,len,input);
}
static hrmv_status legacy_float(hrv_cell v,uint64_t*bits,uint64_t*meta){
 unsigned dec,width;uint64_t abs;
 if(v.tag&~UINT64_C(0x00000000ffffff05))return HRMV_TYPE_UNSUPPORTED;
 /* Width-bearing legacy tags cannot roundtrip through the current legacy
  * compiler decoder (which treats all tag>>8 as decimals). Fail closed. */
 if(v.tag&UINT64_C(0x00000000ffff0000))return HRMV_TYPE_UNSUPPORTED;
 abs=v.payload&UINT64_C(0x7fffffffffffffff);
 if(abs>=UINT64_C(0x7ff0000000000000))return HRMV_TYPE_UNSUPPORTED;
 dec=(unsigned)((v.tag>>8)&255u);if(!dec)dec=2;
 /* IEEE positive magnitudes are bit-ordered. Match BASE legacy thresholds:
  * positive >9999999999.0, negative magnitude >999999999.0 use width20. */
 width=10;
 if((v.payload>>63)?abs>UINT64_C(0x41cdcd64ff800000):abs>UINT64_C(0x4202a05f1ff80000))width=20;
 *bits=v.payload;*meta=((uint64_t)width<<16)|dec;return HRMV_OK;
}
hrmv_status hrmb_get_copy(hrmb_context*c,const char*n,size_t len,hrv_cell*out){
 hrv_cell raw,result;hrmv_status rc;unsigned kind;
 if(!valid(c)||!out)return HRMV_BAD_ARGUMENT;
 rc=hrmv_get_copy(&c->storage,n,len,&raw);if(rc!=HRMV_OK)return rc;
 kind=(unsigned)(raw.tag&255u);result=raw;
 if(kind==HRV_STR_OWN){
  const uint64_t*p=(const uint64_t*)(uintptr_t)raw.payload;
  rc=c->string_copy(c->compiler_user,(const unsigned char*)p,(size_t)p[-1],&result);
 }else if(kind==HRV_DOUBLE){
  uint64_t bits=0,meta=0;
  if(raw.tag==(HR_DYN_FLOAT_HEAP|HR_DYN_FLOAT_KIND)){
   const uint64_t*p=(const uint64_t*)(uintptr_t)raw.payload;bits=p[0];meta=p[1];rc=HRMV_OK;
  }else rc=legacy_float(raw,&bits,&meta);
  if(rc==HRMV_OK)rc=c->float_new(c->compiler_user,bits,meta,&result);
 }
 /* Scalars never own storage bytes; strings/heap floats always release raw.
  * Callback failure must leave result ownership with callback (no transfer).
  * Success callbacks must return their documented compiler-owned cell. */
 if(kind==HRV_STR_OWN||kind==HRV_DOUBLE)hrmv_value_free(&c->storage,&raw);
 if(rc==HRMV_OK)*out=result;
 return rc;
}
