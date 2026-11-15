/* Isolated C API client, not a claim that PRG frontend supports MEMVAR.
 * stdout is paired byte-exactly to storage-oracle.prg on each platform. */
#include "../../runtime/hrmemvar.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
#include <assert.h>
#ifdef _WIN32
#include <io.h>
#include <fcntl.h>
#endif
_Static_assert(sizeof(hrv_cell)==16,"Dyn cell ABI must remain 16 bytes");
static size_t live,allocs,frees,attempts,fail_at;
static void *allocate(void*u,size_t n){void*p;(void)u;attempts++;if(fail_at&&attempts==fail_at)return 0;p=malloc(n);if(p){live+=n;allocs++;}return p;}
static void deallocate(void*u,void*p,size_t n){(void)u;assert(p&&n<=live);live-=n;frees++;free(p);}
#define OK(x) assert((x)==HRMV_OK)
#define NAME(s) s,sizeof(s)-1
static hrv_cell number(int64_t n){hrv_cell v={HRV_I64,(uint64_t)n};return v;}
static hrv_cell string(const char*s){size_t n=strlen(s);uint64_t*p=(uint64_t*)allocate(0,n+9);hrv_cell v;assert(p);*p=n;memcpy(p+1,s,n+1);v.tag=HRV_STR_OWN;v.payload=(uint64_t)(uintptr_t)(p+1);return v;}
static void emit(const char*k,hrv_cell v){
 unsigned t=(unsigned)(v.tag&255u);printf("%s=",k);
 if(t==HRV_NIL)printf("NIL");else if(t==HRV_LOGICAL)printf("%c",v.payload?'T':'F');
 else if(t==HRV_I64||t==HRV_I64_LITERAL)printf("%" PRId64,(int64_t)v.payload);
 else if(t==HRV_STR_OWN){uint64_t*p=(uint64_t*)(uintptr_t)v.payload;fwrite(p,1,(size_t)p[-1],stdout);}else assert(0);
 putchar('\n');
}
static void value(hrmv_context*c,const char*k,const char*n){hrv_cell v;OK(hrmv_get_copy(c,n,strlen(n),&v));emit(k,v);hrmv_value_free(c,&v);}
static void exists(hrmv_context*c,const char*k,const char*n){int yes;hrv_cell v={HRV_LOGICAL,0};OK(hrmv_exists(c,n,strlen(n),&yes));v.payload=(unsigned)yes;emit(k,v);}
static void put(hrmv_context*c,const char*n,int64_t v){OK(hrmv_put_copy(c,n,strlen(n),number(v)));}
static void semantic(hrmv_context*c){
 uint64_t main,child,grand;hrv_cell s,copy;char name[65];
 OK(hrmv_frame_enter(c,&main));
 OK(hrmv_declare_public(c,NAME("pub")));value(c,"public.default","pub");put(c,"pub",50);OK(hrmv_declare_public(c,NAME("pub")));value(c,"public.redeclare","pub");
 OK(hrmv_frame_enter(c,&child));OK(hrmv_declare_private(c,NAME("pub")));put(c,"pub",99);OK(hrmv_release_name(c,NAME("pub")));value(c,"release.shadow","pub");OK(hrmv_frame_leave(c,child));value(c,"release.shadow.restored","pub");
 OK(hrmv_declare_private(c,NAME("p")));put(c,"p",10);
 OK(hrmv_frame_enter(c,&child));value(c,"child.inherited","p");put(c,"p",12);OK(hrmv_declare_private(c,NAME("p")));put(c,"p",20);value(c,"child.shadow","p");
 OK(hrmv_frame_enter(c,&grand));put(c,"p",21);OK(hrmv_frame_leave(c,grand));value(c,"child.after.grand","p");OK(hrmv_frame_leave(c,child));value(c,"parent.restored","p");value(c,"case","P");
 OK(hrmv_frame_enter(c,&child));OK(hrmv_declare_private(c,NAME("p")));put(c,"p",99);OK(hrmv_frame_leave(c,child));value(c,"unwind.restored","p");
 OK(hrmv_declare_private(c,NAME("fresh")));value(c,"private.default","fresh");put(c,"fresh",8);OK(hrmv_declare_private(c,NAME("fresh")));value(c,"private.redeclare","fresh");OK(hrmv_declare_private(c,NAME("fresh")));put(c,"fresh",9);value(c,"private.reinit","fresh");
 OK(hrmv_release_name(c,NAME("fresh")));value(c,"release.private","fresh");exists(c,"release.private.exists","fresh");
 OK(hrmv_declare_public(c,NAME("publicOnly")));exists(c,"public.exists","publicOnly");OK(hrmv_release_name(c,NAME("publicOnly")));exists(c,"release.public.exists","publicOnly");
 OK(hrmv_frame_enter(c,&child));put(c,"implicitNew",88);value(c,"implicit.inside","implicitNew");OK(hrmv_frame_leave(c,child));exists(c,"implicit.after","implicitNew");
 memset(name,'A',63);name[63]=0;put(c,name,11);name[63]='B';name[64]=0;put(c,name,22);name[63]=0;value(c,"long63",name);name[63]='C';name[64]=0;value(c,"long64",name);
 OK(hrmv_declare_private(c,NAME("v")));s=string("first");OK(hrmv_put_copy(c,NAME("v"),s));hrmv_value_free(c,&s);OK(hrmv_get_copy(c,NAME("v"),&copy));s=string("second");OK(hrmv_put_copy(c,NAME("v"),s));hrmv_value_free(c,&s);emit("string.copy",copy);hrmv_value_free(c,&copy);value(c,"string.current","v");s=string("");OK(hrmv_put_copy(c,NAME("v"),s));hrmv_value_free(c,&s);
 s=string("C");emit("empty.type",s);hrmv_value_free(c,&s);OK(hrmv_get_copy(c,NAME("v"),&s));emit("empty.length",number((int64_t)((uint64_t*)(uintptr_t)s.payload)[-1]));hrmv_value_free(c,&s);
 OK(hrmv_declare_public(c,NAME("HARBOUR")));OK(hrmv_declare_public(c,NAME("CLIPPER")));value(c,"default.HARBOUR","HARBOUR");value(c,"default.CLIPPER","CLIPPER");
 OK(hrmv_frame_leave(c,main));assert(c->live_frames==0);
}
static void faults(hrmv_context*c){
 uint64_t a,b,mark=0;hrv_cell before,v,output;size_t bytes,bindings;int found;unsigned i;
 OK(hrmv_frame_enter(c,&a));OK(hrmv_declare_private(c,NAME("v")));v=string("stable");OK(hrmv_put_copy(c,NAME("v"),v));hrmv_value_free(c,&v);
 bytes=live;bindings=c->live_bindings;output=number(123);
 assert(hrmv_get_copy(c,NAME("absent"),&output)==HRMV_UNDEFINED);assert(output.tag==HRV_I64&&output.payload==123);
 assert(hrmv_release_name(c,NAME("absent"))==HRMV_OK);
 assert(hrmv_declare_public(c,NAME("bad-name"))==HRMV_BAD_NAME);
 assert(hrmv_declare_private(c,NAME("bad-name"))==HRMV_BAD_NAME);
 fail_at=attempts+1;assert(hrmv_get_copy(c,NAME("v"),&output)==HRMV_MEMORY);fail_at=0;assert(output.tag==HRV_I64&&output.payload==123&&live==bytes);
 OK(hrmv_get_copy(c,NAME("v"),&before));
 fail_at=attempts+1;assert(hrmv_put_copy(c,NAME("v"),before)==HRMV_MEMORY);fail_at=0;
 OK(hrmv_get_copy(c,NAME("v"),&v));assert(((uint64_t*)(uintptr_t)v.payload)[-1]==6&&!memcmp((void*)(uintptr_t)v.payload,"stable",6));hrmv_value_free(c,&v);
 for(i=1;i<=2;i++){size_t saved=live;fail_at=attempts+i;assert(hrmv_put_copy(c,NAME("newName"),before)==HRMV_MEMORY);fail_at=0;OK(hrmv_exists(c,NAME("newName"),&found));assert(!found&&live==saved&&c->live_bindings==bindings);}
 OK(hrmv_put_copy(c,NAME("v"),before));hrmv_value_free(c,&before);
 bytes=live;fail_at=attempts+1;assert(hrmv_frame_enter(c,&mark)==HRMV_MEMORY);fail_at=0;assert(mark==0&&live==bytes);
 fail_at=attempts+1;assert(hrmv_declare_public(c,NAME("newPublic"))==HRMV_MEMORY);fail_at=0;assert(live==bytes);
 fail_at=attempts+1;assert(hrmv_declare_private(c,NAME("newPrivate"))==HRMV_MEMORY);fail_at=0;assert(live==bytes);
 OK(hrmv_frame_enter(c,&b));assert(hrmv_frame_leave(c,a)==HRMV_BAD_FRAME);OK(hrmv_frame_leave(c,b));assert(hrmv_frame_leave(c,b)==HRMV_BAD_FRAME);
 for(i=0;i<16;i++){hrv_cell unsupported={(uint64_t)i,0};if(i==0||i==1||i==2||i==3||i==4||i==9)continue;assert(hrmv_put_copy(c,NAME("v"),unsupported)==HRMV_TYPE_UNSUPPORTED);}
 v.tag=HRV_DATE;v.payload=20261115;assert(hrmv_put_copy(c,NAME("date"),v)==HRMV_TYPE_UNSUPPORTED);
 {hrv_cell bad={HRV_LOGICAL,2};assert(hrmv_put_copy(c,NAME("v"),bad)==HRMV_TYPE_UNSUPPORTED);bad.tag=HRV_NIL;bad.payload=1;assert(hrmv_put_copy(c,NAME("v"),bad)==HRMV_TYPE_UNSUPPORTED);}
 {uint64_t header[2]={UINT64_MAX,0};hrv_cell huge={HRV_STR_BORROW,(uint64_t)(uintptr_t)(header+1)};assert(hrmv_put_copy(c,NAME("v"),huge)==HRMV_LIMIT);}
 {hrmv_context other;uint64_t id;hrv_cell copy;OK(hrmv_init(&other,allocate,deallocate,0));OK(hrmv_frame_enter(&other,&id));put(&other,"v",777);OK(hrmv_get_copy(&other,NAME("v"),&copy));assert(copy.payload==777);OK(hrmv_get_copy(c,NAME("v"),&copy));assert(copy.tag==HRV_STR_OWN);hrmv_value_free(c,&copy);hrmv_destroy(&other);}
 assert(hrmv_put_copy(c,NAME("bad-name"),number(1))==HRMV_BAD_NAME);assert(hrmv_put_copy(c,"",0,number(1))==HRMV_BAD_NAME);assert(hrmv_put_copy(c,"A\0B",3,number(1))==HRMV_BAD_NAME);
 OK(hrmv_frame_leave(c,a));assert(!c->live_frames);
 assert(hrmv_declare_private(c,NAME("rootPrivate"))==HRMV_BAD_FRAME);
 assert(hrmv_put_copy(c,NAME("rootPrivate"),number(1))==HRMV_BAD_FRAME);
 {uint64_t saved=c->next_frame;c->next_frame=UINT64_MAX;assert(hrmv_frame_enter(c,&mark)==HRMV_LIMIT);c->next_frame=saved;}
 OK(hrmv_frame_enter(c,&a));OK(hrmv_declare_public(c,NAME("persistent")));put(c,"persistent",42);OK(hrmv_frame_leave(c,a));OK(hrmv_get_copy(c,NAME("persistent"),&v));assert(v.payload==42);OK(hrmv_release_name(c,NAME("persistent")));assert(!c->live_bindings);
 /* More than the old flat256 capacity, all simultaneously live. */
 OK(hrmv_frame_enter(c,&a));
 for(i=0;i<600;i++){char key[32];snprintf(key,sizeof(key),"many%u",i);OK(hrmv_put_copy(c,key,strlen(key),number(i)));}
 for(i=0;i<600;i++){char key[32];snprintf(key,sizeof(key),"MANY%u",i);OK(hrmv_get_copy(c,key,strlen(key),&v));assert(v.payload==i);}
 OK(hrmv_frame_leave(c,a));assert(!c->live_bindings&&!c->live_frames);
 for(i=0;i<1000;i++){char key[32];OK(hrmv_frame_enter(c,&a));snprintf(key,sizeof(key),"key%u",i);OK(hrmv_declare_private(c,key,strlen(key)));v=string("payload");OK(hrmv_put_copy(c,key,strlen(key),v));hrmv_value_free(c,&v);OK(hrmv_release_name(c,key,strlen(key)));OK(hrmv_get_copy(c,key,strlen(key),&v));assert(v.tag==HRV_NIL);hrmv_value_free(c,&v);OK(hrmv_frame_leave(c,a));}
}
int main(int argc,char**argv){
 hrmv_context c;
#ifdef _WIN32
 /* OutStd(Chr(10)) in the PRG oracle writes raw LF. Avoid CRT translation
  * at the actual output boundary, never normalize captured evidence. */
 assert(_setmode(_fileno(stdout),_O_BINARY)!=-1);
#endif
 OK(hrmv_init(&c,allocate,deallocate,0));
 if(argc>1&&!strcmp(argv[1],"faults")){faults(&c);hrmv_destroy(&c);assert(!live&&allocs==frees);printf("faults=PASS\nlive_bytes=0\nallocations=%zu\nfrees=%zu\n",allocs,frees);}
 else{semantic(&c);hrmv_destroy(&c);assert(!live&&allocs==frees);}
 hrmv_destroy(&c);assert(!live);return 0;
}
