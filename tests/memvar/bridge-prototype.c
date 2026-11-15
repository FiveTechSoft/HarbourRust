/* Isolated bridge prototype. Fake compiler allocator, not hbc helpers.
 * These tests prove ownership mechanics only, not emitted ABI/registry. */
#include "../../runtime/hrmemvar.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef _WIN32
#include <fcntl.h>
#include <io.h>
#endif
typedef struct block { void *p; size_t n; struct block *next; } block;
typedef struct {block *head;size_t live,allocs,frees,attempts,fail;} pool;
static void *raw_alloc(void *user,size_t n){pool *p=user;block*b;void*v;p->attempts++;if(p->fail==p->attempts)return 0;v=malloc(n);if(!v)return 0;b=malloc(sizeof(*b));assert(b);b->p=v;b->n=n;b->next=p->head;p->head=b;p->live+=n;p->allocs++;return v;}
static void raw_free(void *user,void*v,size_t n){pool*p=user;block**b=&p->head,*old;while(*b&&(*b)->p!=v)b=&(*b)->next;assert(*b&&(*b)->n==n);old=*b;*b=old->next;p->live-=n;p->frees++;free(v);free(old);}
static unsigned char *fake_hrm_alloc(pool*p,size_t n){uint64_t*b;if(n>SIZE_MAX-17)return 0;b=raw_alloc(p,n+17);if(!b)return 0;b[0]=n;b[1]=n;((unsigned char*)(b+2))[n]=0;return (unsigned char*)(b+2);}
static void fake_hrm_free(pool*p,unsigned char*v){uint64_t*b=(uint64_t*)v;raw_free(p,b-2,(size_t)b[-2]+17);}
static hrmv_status bridge_get(hrmv_context*c,pool*compiler,const char*name,size_t len,hrv_cell*out){hrv_cell v;hrmv_status rc=hrmv_get_copy(c,name,len,&v);if(rc!=HRMV_OK)return rc;if(v.tag==HRV_STR_OWN){uint64_t*p=(uint64_t*)(uintptr_t)v.payload;size_t n=(size_t)p[-1];unsigned char*copy=fake_hrm_alloc(compiler,n);if(!copy){hrmv_value_free(c,&v);return HRMV_MEMORY;}memcpy(copy,p,n);hrmv_value_free(c,&v);v.tag=HRV_STR_OWN;v.payload=(uint64_t)(uintptr_t)copy;}*out=v;return HRMV_OK;}
static void expect_value(hrv_cell v,const unsigned char*b,size_t n){uint64_t*p=(uint64_t*)(uintptr_t)v.payload;assert(v.tag==HRV_STR_OWN&&p[-1]==n&&!memcmp(p,b,n));}
#define OK(x) assert((x)==HRMV_OK)
static void one(size_t n){pool store={0},compiler={0};hrmv_context c;uint64_t frame,child;hrv_cell in,out,old,check;unsigned char*p;size_t bytes;char a[66],b[66];
 OK(hrmv_init(&c,raw_alloc,raw_free,&store));OK(hrmv_frame_enter(&c,&frame));p=fake_hrm_alloc(&compiler,n);assert(p);for(size_t i=0;i<n;i++)p[i]=(unsigned char)(i%251);in.tag=HRV_STR_OWN;in.payload=(uint64_t)(uintptr_t)p;
 OK(hrmv_put_copy(&c,"text",4,in));OK(bridge_get(&c,&compiler,"text",4,&out));expect_value(out,p,n);assert(out.payload!=in.payload);fake_hrm_free(&compiler,(void*)(uintptr_t)out.payload);
 bytes=store.live;old.tag=HRV_I64;old.payload=987;store.fail=store.attempts+1;out=old;assert(bridge_get(&c,&compiler,"text",4,&out)==HRMV_MEMORY);store.fail=0;assert(out.tag==old.tag&&out.payload==old.payload&&store.live==bytes);
 compiler.fail=compiler.attempts+1;out=old;assert(bridge_get(&c,&compiler,"text",4,&out)==HRMV_MEMORY);compiler.fail=0;assert(out.tag==old.tag&&out.payload==old.payload&&store.live==bytes);
 store.fail=store.attempts+1;assert(hrmv_put_copy(&c,"text",4,in)==HRMV_MEMORY);store.fail=0;OK(bridge_get(&c,&compiler,"text",4,&out));expect_value(out,p,n);fake_hrm_free(&compiler,(void*)(uintptr_t)out.payload);
 OK(hrmv_frame_enter(&c,&child));OK(hrmv_declare_private(&c,"text",4));OK(hrmv_put_copy(&c,"text",4,old));OK(hrmv_frame_leave(&c,child));OK(bridge_get(&c,&compiler,"text",4,&out));expect_value(out,p,n);fake_hrm_free(&compiler,(void*)(uintptr_t)out.payload);
 memset(a,'A',63);a[63]='X';a[64]=0;memcpy(b,a,65);b[63]='Y';OK(hrmv_put_copy(&c,a,64,old));OK(bridge_get(&c,&compiler,b,64,&out));assert(out.tag==old.tag&&out.payload==old.payload);
 for(unsigned t=5;t<16;t++){if(t==9)continue;check.tag=t;check.payload=0;assert(hrmv_put_copy(&c,"text",4,check)==HRMV_TYPE_UNSUPPORTED);}
 fake_hrm_free(&compiler,p);OK(bridge_get(&c,&compiler,"text",4,&out));assert(((uint64_t*)(uintptr_t)out.payload)[-1]==n);fake_hrm_free(&compiler,(void*)(uintptr_t)out.payload);
 OK(hrmv_frame_leave(&c,frame));assert(!c.live_frames&&!c.live_bindings);hrmv_destroy(&c);assert(!store.live&&!compiler.live&&!store.head&&!compiler.head&&store.allocs==store.frees&&compiler.allocs==compiler.frees);
 printf("bridge.length.%zu=PASS\n",n);
}
int main(void){
#ifdef _WIN32
assert(_setmode(_fileno(stdout),_O_BINARY)!=-1);
#endif
one(0);one(7);one(4096);one(65537);puts("bridge.raw_and_fake_compiler_live=0");return 0;}
