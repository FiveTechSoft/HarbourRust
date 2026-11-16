#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "../../../runtime/hrmacro.c"
static size_t live,allocs,frees,attempt,failat;
typedef struct B {size_t n;} B;
static void *backalloc(void*u,size_t n){(void)u;if(++attempt==failat)return 0;B*b=malloc(n+sizeof(*b));assert(b);b->n=n;live+=n;allocs++;memset(b+1,0xa5,n);return b+1;}
static void backfree(void*u,void*p,size_t n){(void)u;B*b=(B*)p-1;assert(b->n==n);live-=n;frees++;free(b);}
void hrm_fail(const unsigned char*s,size_t n){fwrite(s,1,n,stderr);abort();}
static hrmacro_raw_pool fresh(void){hrmacro_raw_pool p={0};p.alloc=backalloc;p.free=backfree;return p;}
int main(int argc,char**argv){
 hrmacro_raw_pool p=fresh(),q=fresh();
 if(argc>1){void*x=raw_reuse_alloc(&p,64);if(!strcmp(argv[1],"double")){raw_reuse_free(&p,x,64);raw_reuse_free(&p,x,64);}else if(!strcmp(argv[1],"size"))raw_reuse_free(&p,x,63);else raw_reuse_free(&q,x,64);return 99;}
 size_t sizes[]={0,1,63,64,65,255,256,257,1023,1024,1025,4095,4096,4097,8192};
 for(size_t i=0;i<sizeof sizes/sizeof *sizes;i++){size_t n=sizes[i];unsigned char*a=raw_reuse_alloc(&p,n);assert(a);for(size_t j=0;j<n;j++)assert(a[j]==0);memset(a,0xcc,n);raw_reuse_free(&p,a,n);a=raw_reuse_alloc(&p,n);for(size_t j=0;j<n;j++)assert(a[j]==0);raw_reuse_free(&p,a,n);assert(p.retained<=HRM_POOL_CAP);}
 void*a=raw_reuse_alloc(&p,64),*b=raw_reuse_alloc(&q,64);assert(a!=b);raw_reuse_free(&p,a,64);raw_reuse_free(&q,b,64);
 void*items[512];for(unsigned i=0;i<512;i++)items[i]=raw_reuse_alloc(&p,1024);for(unsigned i=0;i<512;i++)raw_reuse_free(&p,items[i],1024);assert(p.retained<=HRM_POOL_CAP&&!p.live_blocks&&!p.live_bytes);
 assert(!raw_reuse_alloc(&p,SIZE_MAX));failat=attempt+1;assert(!raw_reuse_alloc(&p,9999));failat=0;a=raw_reuse_alloc(&p,9999);assert(a);raw_reuse_free(&p,a,9999);
 raw_reuse_destroy(&p);raw_reuse_destroy(&q);raw_reuse_destroy(&p);assert(!live&&allocs==frees&&!p.retained&&!p.all&&!q.all);puts("P1.pool.classes.zeroing.contexts.cap.includes_headers.fault.retry.overflow.destroy=PASS");return 0;
}
