#include "../runtime/hrmembridge.h"
#include "../runtime/hrdyn.h"
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#ifdef _WIN32
#include <fcntl.h>
#include <io.h>
#endif
typedef struct block{void*p;size_t n;struct block*next;}block;
typedef struct{block*head;size_t live,count,freed,attempt,fail,floats16;}pool;
static void*alloc(void*u,size_t n){pool*p=u;block*b;void*v;p->attempt++;if(p->fail==p->attempt)return 0;v=malloc(n);if(!v)return 0;b=malloc(sizeof(*b));assert(b);b->p=v;b->n=n;b->next=p->head;p->head=b;p->live+=n;p->count++;return v;}
static void release(void*u,void*v,size_t n){pool*p=u;block**b=&p->head,*old;while(*b&&(*b)->p!=v)b=&(*b)->next;assert(*b&&(*b)->n==n);old=*b;*b=old->next;p->live-=n;p->freed++;if(n==16)p->floats16++;free(old);free(v);}
static hrmv_status strcopy(void*u,const unsigned char*s,size_t n,hrv_cell*out){uint64_t*p=alloc(u,n+17);if(!p)return HRMV_MEMORY;p[0]=n;p[1]=n;memcpy(p+2,s,n);((unsigned char*)(p+2))[n]=0;out->tag=4;out->payload=(uint64_t)(uintptr_t)(p+2);return HRMV_OK;}
static hrmv_status floating(void*u,uint64_t bits,uint64_t meta,hrv_cell*out){uint64_t*p=alloc(u,32);if(!p)return HRMV_MEMORY;p[0]=16;p[1]=16;p[2]=bits;p[3]=meta;out->tag=HR_DYN_FLOAT_HEAP|5;out->payload=(uint64_t)(uintptr_t)(p+2);return HRMV_OK;}
static void drop(pool*p,hrv_cell v){uint64_t*b=(uint64_t*)(uintptr_t)v.payload;if(v.tag==4)release(p,b-2,(size_t)b[-1]+17);else if(v.tag==(HR_DYN_FLOAT_HEAP|5))release(p,b-2,32);}
#define OK(x) assert((x)==HRMV_OK)
static void check_heap(hrv_cell v,uint64_t bits,uint64_t meta){uint64_t*p=(uint64_t*)(uintptr_t)v.payload;assert(v.tag==(HR_DYN_FLOAT_HEAP|5)&&p[0]==bits&&p[1]==meta);}
int main(void){pool raw={0},compiler={0};hrmb_context c,other;uint64_t mark,child,m2;hrv_cell v,out,before;size_t saved;char a[66],b[66];
#ifdef _WIN32
assert(_setmode(_fileno(stdout),_O_BINARY)!=-1);
#endif
OK(hrmb_init(&c,alloc,release,&raw,strcopy,floating,&compiler));OK(hrmb_frame_enter(&c,&mark));
OK(floating(&compiler,UINT64_C(0x400c000000000000),(12u<<16)|4u,&v));OK(hrmb_declare_put(&c,1,"valor",5,v));drop(&compiler,v);OK(hrmb_get_copy(&c,"VALOR",5,&out));check_heap(out,UINT64_C(0x400c000000000000),(12u<<16)|4u);drop(&compiler,out);puts("heap.copy.bits_meta=PASS");
saved=raw.live;before.tag=0;before.payload=987;out=before;raw.fail=raw.attempt+1;assert(hrmb_get_copy(&c,"valor",5,&out)==HRMV_MEMORY);raw.fail=0;assert(out.tag==0&&out.payload==987&&raw.live==saved);compiler.fail=compiler.attempt+1;assert(hrmb_get_copy(&c,"valor",5,&out)==HRMV_MEMORY);compiler.fail=0;assert(out.tag==0&&out.payload==987&&raw.live==saved);puts("heap.copy.failures=PASS");
OK(strcopy(&compiler,(const unsigned char*)"a\0b",3,&v));OK(hrmb_declare_put(&c,1,"foo",3,v));drop(&compiler,v);OK(hrmb_declare_put(&c,1,"foobar",6,before));OK(hrmb_get_copy(&c,"FOO",3,&out));assert(out.tag==4&&((uint64_t*)(uintptr_t)out.payload)[-1]==3&&!memcmp((void*)(uintptr_t)out.payload,"a\0b",3));drop(&compiler,out);puts("string.case.prefix.copy=PASS");
OK(hrmb_frame_enter(&c,&child));OK(hrmb_declare(&c,1,"valor",5));OK(hrmb_get_copy(&c,"valor",5,&out));assert(out.tag==1);OK(hrmb_frame_leave(&c,child));OK(hrmb_get_copy(&c,"valor",5,&out));check_heap(out,UINT64_C(0x400c000000000000),(12u<<16)|4u);drop(&compiler,out);puts("frame.shadow.restore=PASS");
memset(a,'A',63);a[63]='X';a[64]=0;memcpy(b,a,65);b[63]='Y';OK(hrmb_declare_put(&c,1,a,64,before));OK(hrmb_get_copy(&c,b,64,&out));assert(out.payload==987);puts("name.truncate63=PASS");
for(unsigned d=0;d<=255;d++){v.tag=5|((uint64_t)d<<8);v.payload=UINT64_C(0x400c000000000000);OK(hrmb_declare_put(&c,1,"legacy",6,v));OK(hrmb_get_copy(&c,"legacy",6,&out));check_heap(out,v.payload,(10u<<16)|(d?d:2u));drop(&compiler,out);}puts("legacy.dec0_255=PASS");
v.tag=5|(12u<<16);v.payload=0;OK(hrmb_declare_put(&c,1,"legacy",6,v));out=before;assert(hrmb_get_copy(&c,"legacy",6,&out)==HRMV_TYPE_UNSUPPORTED&&out.payload==987);v.tag=5;v.payload=UINT64_C(0x7ff8000000000042);OK(hrmb_declare_put(&c,1,"legacy",6,v));assert(hrmb_get_copy(&c,"legacy",6,&out)==HRMV_TYPE_UNSUPPORTED);puts("legacy.export.limits=PASS");
/* Bit-preserving heap and inline storage, reserved tags and export limits. */
{
 const uint64_t patterns[]={0,UINT64_C(0x8000000000000000),UINT64_C(0x7ff0000000000000),UINT64_C(0x7ff8000000000042),UINT64_MAX};
 for(size_t i=0;i<sizeof(patterns)/sizeof(patterns[0]);i++){
  uint64_t item[2]={patterns[i],UINT64_MAX};hrv_cell input={HR_DYN_FLOAT_HEAP|5,(uint64_t)(uintptr_t)item};
  OK(hrmv_put_copy(&c.storage,"bits",4,input));item[0]=123;item[1]=456;
  OK(hrmv_get_copy(&c.storage,"bits",4,&out));check_heap(out,patterns[i],UINT64_MAX);hrmv_value_free(&c.storage,&out);
  input.tag=5|(255u<<8)|(65535u<<16);input.payload=patterns[i];saved=raw.count;OK(hrmv_put_copy(&c.storage,"bits",4,input));OK(hrmv_get_copy(&c.storage,"bits",4,&out));assert(out.tag==input.tag&&out.payload==input.payload&&raw.count==saved);hrmv_value_free(&c.storage,&out);
 }
 hrv_cell bad={HR_DYN_FLOAT_HEAP|5,0};assert(hrmv_put_copy(&c.storage,"bits",4,bad)==HRMV_BAD_ARGUMENT);
 bad.tag=(HR_DYN_FLOAT_HEAP|5)|(1u<<8);assert(hrmv_put_copy(&c.storage,"bits",4,bad)==HRMV_TYPE_UNSUPPORTED);
 bad.tag=UINT64_C(0x100000005);assert(hrmv_put_copy(&c.storage,"bits",4,bad)==HRMV_TYPE_UNSUPPORTED);
 const hrv_cell scalars[]={{0,17},{9,19},{1,0},{3,0},{3,1}};
 for(size_t i=0;i<sizeof(scalars)/sizeof(scalars[0]);i++){OK(hrmb_declare_put(&c,1,"scalar",6,scalars[i]));OK(hrmb_get_copy(&c,"scalar",6,&out));assert(out.tag==scalars[i].tag&&out.payload==scalars[i].payload);}
 size_t count=c.storage.live_bindings;out=before;assert(hrmb_get_copy(&c,"unknown",7,&out)==HRMV_UNDEFINED&&out.payload==987&&c.storage.live_bindings==count);
 assert(hrmb_declare(&c,1,"árbol",6)==HRMV_BAD_NAME);
}
puts("opaque_bits.scalars.invalid=PASS");
/* C12: declaration persists after the separate put fails, then retry. */
OK(strcopy(&compiler,(const unsigned char*)"retry",5,&v));
for(int priv=0;priv<=1;priv++){
 const char*name=priv?"newprivate":"newpublic";size_t len=strlen(name);
 OK(hrmb_declare(&c,priv,name,len));saved=raw.live;
 raw.fail=raw.attempt+1;assert(hrmv_put_copy(&c.storage,name,len,v)==HRMV_MEMORY);raw.fail=0;
 OK(hrmb_get_copy(&c,name,len,&out));assert(out.tag==(priv?1u:3u)&&out.payload==0&&raw.live==saved);
 hrv_cell unsupported={11,0};assert(hrmv_put_copy(&c.storage,name,len,unsupported)==HRMV_TYPE_UNSUPPORTED);
 OK(hrmb_get_copy(&c,name,len,&out));assert(out.tag==(priv?1u:3u)&&out.payload==0);
 OK(hrmv_put_copy(&c.storage,name,len,v));OK(hrmb_get_copy(&c,name,len,&out));assert(out.tag==4&&!memcmp((void*)(uintptr_t)out.payload,"retry",5));drop(&compiler,out);
 OK(hrmv_release_name(&c.storage,name,len));
}
/* The convenience declare_put has the same two-step state. */
for(int priv=0;priv<=1;priv++){
 const char*name=priv?"combinedpriv":"combinedpub";size_t len=strlen(name);
 raw.fail=raw.attempt+2;assert(hrmb_declare_put(&c,priv,name,len,v)==HRMV_MEMORY);raw.fail=0;
 OK(hrmb_get_copy(&c,name,len,&out));assert(out.tag==(priv?1u:3u)&&out.payload==0);
 OK(hrmv_put_copy(&c.storage,name,len,v));OK(hrmb_get_copy(&c,name,len,&out));assert(out.tag==4);drop(&compiler,out);OK(hrmv_release_name(&c.storage,name,len));
}
drop(&compiler,v);puts("declare.failed_put.default.retry=PASS");
/* Heap put: existing value transactional; new binding rollback before publish. */
{
 uint64_t heap[2]={UINT64_C(0x4014000000000000),655364};hrv_cell hv={HR_DYN_FLOAT_HEAP|5,(uint64_t)(uintptr_t)heap};
 for(unsigned step=1;step<=2;step++){
  size_t bindings=c.storage.live_bindings;saved=raw.live;raw.fail=raw.attempt+step;
  assert(hrmv_put_copy(&c.storage,"newheap",7,hv)==HRMV_MEMORY);raw.fail=0;
  assert(raw.live==saved&&c.storage.live_bindings==bindings);
  assert(hrmb_get_copy(&c,"newheap",7,&out)==HRMV_UNDEFINED);
 }
 saved=raw.live;raw.fail=raw.attempt+1;assert(hrmv_put_copy(&c.storage,"valor",5,hv)==HRMV_MEMORY);raw.fail=0;
 assert(raw.live==saved);OK(hrmb_get_copy(&c,"valor",5,&out));check_heap(out,UINT64_C(0x400c000000000000),(12u<<16)|4u);drop(&compiler,out);
 size_t bindings=c.storage.live_bindings;saved=raw.live;raw.fail=raw.attempt+1;assert(hrmb_declare(&c,1,"no_decl",7)==HRMV_MEMORY);raw.fail=0;assert(raw.live==saved&&c.storage.live_bindings==bindings);
}
puts("heap.put.transaction.failpoints=PASS");

OK(hrmb_init(&other,alloc,release,&raw,strcopy,floating,&compiler));OK(hrmb_frame_enter(&other,&m2));out=before;assert(hrmb_get_copy(&other,"valor",5,&out)==HRMV_UNDEFINED);assert(!other.storage.live_bindings);hrmb_destroy(&other);OK(hrmb_frame_leave(&c,mark));assert(!c.storage.live_frames&&!c.storage.live_bindings);hrmb_destroy(&c);assert(!raw.live&&!compiler.live&&raw.count==raw.freed&&compiler.count==compiler.freed&&raw.floats16);puts("raw.compiler.live=0");return 0;}
