/* Own MIT compiler-facing single-area adapter. Linux only. */
#include "hrdbf_file.h"
#include "hrvalue.h"
/* C static storage supplies zero-init by construction. No caller-init grant. */
static hrdbf_file hrdbf_app_state;
static hrntx_file hrdbf_app_order;
static uint64_t hrdbf_app_pos;
static unsigned hrdbf_app_found_flag;
static void hrdbf_app_fail(const char *msg){
 size_t n=0;while(msg[n])n++;
 syscall3(1,2,(long)msg,n);
 hrntx_file_close(&hrdbf_app_order);
 hrdbf_file_close(&hrdbf_app_state);
 syscall3(60,1,0,0);__builtin_unreachable();
}
static void hrdbf_app_require(void){if(!hrdbf_app_state.area.open)hrdbf_app_fail("hbc: DBF no workarea is open\n");}
void hrdbf_app_close(void){hrdbf_error a=hrntx_file_close(&hrdbf_app_order),b=hrdbf_file_close(&hrdbf_app_state);hrdbf_app_found_flag=0;hrdbf_app_pos=0;if(a||b)hrdbf_app_fail("hbc: DBF/NTX close failed\n");}
void hrdbf_app_open(const unsigned char *p,size_t len,uint64_t new_area){
 char path[4096];size_t i;hrdbf_error e;
 if(new_area&&hrdbf_app_state.area.open)hrdbf_app_fail("hbc: DBF only one workarea is supported\n");
 if(!len||len>=sizeof path)hrdbf_app_fail("hbc: DBF filename length outside supported range\n");
 for(i=0;i<len;i++){if(!p[i])hrdbf_app_fail("hbc: DBF filename contains NUL\n");path[i]=(char)p[i];}path[len]=0;
 if(hrntx_file_close(&hrdbf_app_order))hrdbf_app_fail("hbc: NTX close failed\n");
 hrdbf_app_found_flag=0;hrdbf_app_pos=0;
 e=hrdbf_file_open(&hrdbf_app_state,path);
 if(e)hrdbf_app_fail("hbc: DBF read-only open rejected (format, data, size or I/O)\n");
}
static void hrdbf_app_order_sync(void){
 hrdbf_area*d=&hrdbf_app_state.area;hrntx_index*x=&hrdbf_app_order.index;
 d->recno=hrdbf_app_pos<x->count?x->entries[hrdbf_app_pos].recno:(uint64_t)d->count+1;
 d->eof=hrdbf_app_pos>=x->count;
}
void hrdbf_app_top(void){
 hrdbf_app_require();hrdbf_app_found_flag=0;
 if(!hrdbf_app_order.index.bytes){hrdbf_top(&hrdbf_app_state.area);return;}
 hrdbf_app_pos=0;hrdbf_app_order_sync();hrdbf_app_state.area.bof=!hrdbf_app_order.index.count;
}
void hrdbf_app_bottom(void){
 hrdbf_area*d=&hrdbf_app_state.area;hrntx_index*x=&hrdbf_app_order.index;
 hrdbf_app_require();hrdbf_app_found_flag=0;
 if(!x->bytes){d->recno=d->count?d->count:1;d->bof=d->eof=!d->count;return;}
 hrdbf_app_pos=x->count?x->count-1:0;hrdbf_app_order_sync();d->bof=!x->count;
}
void hrdbf_app_skip(int64_t n){
 hrdbf_area*d=&hrdbf_app_state.area;hrntx_index*x=&hrdbf_app_order.index;uint64_t m;
 hrdbf_app_require();hrdbf_app_found_flag=0;
 if(!x->bytes){hrdbf_skip(d,n);return;}
 if(!n)return;
 d->bof=0;
 if(n>0){m=(uint64_t)n;hrdbf_app_pos=m>x->count-hrdbf_app_pos?x->count:hrdbf_app_pos+m;}
 else{m=(uint64_t)(-(n+1))+1;if(m>hrdbf_app_pos){hrdbf_app_pos=0;d->bof=1;}else hrdbf_app_pos-=m;}
 hrdbf_app_order_sync();
}
uint64_t hrdbf_app_order_add(const unsigned char*p,size_t len){
 char path[4096];size_t i,last=0;int dot=0;
 hrdbf_app_require();
 if(hrdbf_app_order.index.bytes)hrdbf_app_fail("hbc: NTX only one index is supported\n");
 if(!len||len>sizeof(path)-5)hrdbf_app_fail("hbc: NTX filename length outside supported range\n");
 for(i=0;i<len;i++){if(!p[i])hrdbf_app_fail("hbc: NTX filename contains NUL\n");path[i]=(char)p[i];if(p[i]=='/')last=i+1;}
 for(i=last;i<len;i++)if(p[i]=='.')dot=1;
 if(!dot){path[len++]='.';path[len++]='n';path[len++]='t';path[len++]='x';}path[len]=0;
 if(hrntx_file_open(&hrdbf_app_order,path,&hrdbf_app_state.area))hrdbf_app_fail("hbc: NTX read-only open rejected (subset, format, DBF mismatch, size or I/O)\n");
 hrdbf_app_top();return 1;
}
void hrdbf_app_order_clear(void){hrdbf_app_require();if(hrntx_file_close(&hrdbf_app_order))hrdbf_app_fail("hbc: NTX close failed\n");hrdbf_app_pos=0;}
uint64_t hrdbf_app_found(void){hrdbf_app_require();return hrdbf_app_found_flag;}
uint64_t hrdbf_app_seek(const unsigned char*p,size_t n,uint64_t soft,uint64_t last){
 int found;hrntx_index*x=&hrdbf_app_order.index;hrdbf_app_require();
 if(!x->bytes)hrdbf_app_fail("hbc: NTX seek requires an open index\n");
 hrdbf_app_pos=hrntx_seek(x,p,n,soft!=0,last!=0,&found);hrdbf_app_found_flag=found;hrdbf_app_order_sync();hrdbf_app_state.area.bof=!x->count;return found;
}
uint64_t hrdbf_app_recno(void){hrdbf_app_require();return hrdbf_app_state.area.recno;}
uint64_t hrdbf_app_lastrec(void){hrdbf_app_require();return hrdbf_app_state.area.count;}
uint64_t hrdbf_app_bof(void){hrdbf_app_require();return hrdbf_app_state.area.bof;}
uint64_t hrdbf_app_eof(void){hrdbf_app_require();return hrdbf_app_state.area.eof;}
uint64_t hrdbf_app_deleted(void){unsigned char d;hrdbf_app_require();hrdbf_deleted(&hrdbf_app_state.area,&d);return d;}
hrv_cell hrdbf_app_get(int64_t n,void *(*copy)(const void*,size_t)){
 hrdbf_value v;hrv_cell c={HRV_NIL,0};unsigned char spaces[255];size_t i;
 hrdbf_app_require();
 if(n<1||n>hrdbf_app_state.area.nfields)return c;
 if(hrdbf_get(&hrdbf_app_state.area,(unsigned)n,&v))hrdbf_app_fail("hbc: DBF field decoding failed\n");
 if(v.type=='C'){
  if(!v.text){for(i=0;i<v.width;i++)spaces[i]=' ';v.text=spaces;}
  c.tag=HRV_STR_OWN;c.payload=(uint64_t)copy(v.text,v.width);if(!c.payload)hrdbf_app_fail("hbc: DBF field string allocation failed\n");return c;
 }
 if(v.type=='N')return hrv_number(v.scaled,v.width,v.decimals);
 if(v.type=='D')return hrv_date(v.date);
 c.tag=HRV_LOGICAL;c.payload=v.logical;return c;
}
size_t hrdbf_app_render(uint64_t tag,uint64_t pay,unsigned char *out){
 hrv_cell c={tag,pay};size_t n=0;hrv_error e=hrv_render(c,out,256,&n);
 if(e)hrdbf_app_fail("hbc: DBF scalar render rejected\n");return n;
}
int64_t hrdbf_app_integer(uint64_t tag,uint64_t pay){
 hrv_cell c={tag,pay};int64_t n;hrv_error e=hrv_i64(c,&n);
 if(e==HRV_DECIMAL_I64)hrdbf_app_fail("hbc: DBF decimal numeric cannot enter I64 operation\n");
 if(e)hrdbf_app_fail("hbc: DBF scalar cannot enter I64 operation\n");return n;
}
uint64_t hrdbf_app_equal(uint64_t ta,uint64_t pa,uint64_t tb,uint64_t pb){
 hrv_cell a={ta,pa},b={tb,pb};int yes;hrv_error e=hrv_equal(a,b,&yes);
 if(e==HRV_DECIMAL_I64)hrdbf_app_fail("hbc: DBF decimal numeric cannot enter I64 operation\n");
 if(e)hrdbf_app_fail("hbc: DBF scalar comparison is outside this increment\n");return (uint64_t)yes;
}
int64_t hrdbf_app_compare(uint64_t ta,uint64_t pa,uint64_t tb,uint64_t pb){
 hrv_cell a={ta,pa},b={tb,pb};int64_t x,y;
 if(hrv_kind(a)==HRV_DATE&&hrv_kind(b)==HRV_DATE){if(hrv_validate(a)||hrv_validate(b))hrdbf_app_fail("hbc: DBF invalid Date comparison\n");return pa<pb?-1:pa>pb;}
 x=hrdbf_app_integer(ta,pa);y=hrdbf_app_integer(tb,pb);return x<y?-1:x>y;
}
uint64_t hrdbf_app_empty(uint64_t t,uint64_t p){
 hrv_cell c={t,p};unsigned k=hrv_kind(c);int yes;hrv_error e;
 if(k==HRV_STR_OWN||k==HRV_STR_BORROW){size_t i,n=((const uint64_t*)p)[-1];const unsigned char*s=(const unsigned char*)p;for(i=0;i<n;i++)if(s[i]!=' '&&s[i]!=9&&s[i]!=10&&s[i]!=13)return 0;return 1;}
 if(k==HRV_ARRAY)return !p||!((const uint64_t*)p)[-1];
 if(k==HRV_DOUBLE){union{uint64_t u;double d;}v;v.u=p;return v.d==0.0;}
 if(k==HRV_BLOCK)return 0;
 e=hrv_empty(c,&yes);if(e)hrdbf_app_fail("hbc: DBF scalar Empty rejected\n");return (uint64_t)yes;
}
void hrdbf_app_unsupported(void){hrdbf_app_fail("hbc: DBF-active dynamic scalar consumer is outside the admitted subset\n");}
