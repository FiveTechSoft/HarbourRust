/* Own MIT MEMVAR storage, freestanding and context-owned. No Harbour code. */
#include "hrmemvar.h"
#include <stdint.h>

typedef struct hrmv_binding {
 struct hrmv_binding *next;
 uint64_t owner; /* zero = PUBLIC, nonzero = PRIVATE frame */
 hrv_cell value;
 char name[HRMV_NAME_MAX+1];
} hrmv_binding;
typedef struct hrmv_frame {
 struct hrmv_frame *previous;
 uint64_t id;
} hrmv_frame;

static int valid(const hrmv_context *c){return c&&c->alloc&&c->free;}
static unsigned char upper(unsigned char b){return b>='a'&&b<='z'?b-32:b;}
static int letter(unsigned char b){return (b>='a'&&b<='z')||(b>='A'&&b<='Z')||b=='_';}
/* ASCII-only first gate. Harbour truncates symbol names at 63 bytes. Reject
 * unsupported spelling even in the truncated suffix rather than accepting
 * codepage/embedded-NUL ambiguities as if they were Harbour-compatible. */
static hrmv_status name_key(const char *p,size_t n,char key[HRMV_NAME_MAX+1]){
 size_t i,m;
 if(!p||!n)return HRMV_BAD_NAME;
 for(i=0;i<n;i++){
  unsigned char b=(unsigned char)p[i];
  if(!letter(b)&&!(i&&b>='0'&&b<='9'))return HRMV_BAD_NAME;
 }
 m=n>HRMV_NAME_MAX?HRMV_NAME_MAX:n;
 for(i=0;i<m;i++)key[i]=(char)upper((unsigned char)p[i]);
 key[m]=0;return HRMV_OK;
}
static int same(const char *a,const char *b){size_t i=0;while(a[i]&&a[i]==b[i])i++;return a[i]==b[i];}
static hrmv_binding *find(hrmv_context*c,const char *key){
 hrmv_binding*b=(hrmv_binding*)c->bindings;for(;b;b=b->next)if(same(b->name,key))return b;return 0;
}
static void copy_name(char*d,const char*s){size_t i=0;do{d[i]=s[i];}while(s[i++]);}
static hrv_cell nil(void){hrv_cell v={HRV_NIL,0};return v;}
void hrmv_value_free(hrmv_context*c,hrv_cell*v){
 if(!v)return;
 if(valid(c)&&v->tag==HRV_STR_OWN&&v->payload){
  uint64_t *p=(uint64_t*)(uintptr_t)v->payload;
  c->free(c->user,p-1,(size_t)p[-1]+sizeof(uint64_t)+1);
 }
 *v=nil();
}
static hrmv_status value_copy(hrmv_context*c,hrv_cell v,hrv_cell*out){
 unsigned k=(unsigned)(v.tag&255u);
 if(k==HRV_I64||k==HRV_I64_LITERAL||k==HRV_NIL||k==HRV_LOGICAL){
  if(v.tag!=k||(k==HRV_NIL&&v.payload)||(k==HRV_LOGICAL&&v.payload>1))return HRMV_TYPE_UNSUPPORTED;
  *out=v;return HRMV_OK;
 }
 if((k==HRV_STR_BORROW||k==HRV_STR_OWN)&&v.tag==k){
  const uint64_t *src=(const uint64_t*)(uintptr_t)v.payload;
  uint64_t n;uint64_t*dst;size_t i,total;
  if(!src)return HRMV_BAD_ARGUMENT;
  n=src[-1];
  if(n>SIZE_MAX-sizeof(uint64_t)-1)return HRMV_LIMIT;
  total=(size_t)n+sizeof(uint64_t)+1;
  dst=(uint64_t*)c->alloc(c->user,total);if(!dst)return HRMV_MEMORY;
  dst[0]=n;
  for(i=0;i<(size_t)n;i++)((unsigned char*)(dst+1))[i]=((const unsigned char*)src)[i];
  ((unsigned char*)(dst+1))[n]=0;
  out->tag=HRV_STR_OWN;out->payload=(uint64_t)(uintptr_t)(dst+1);return HRMV_OK;
 }
 /* Dates (D), float/decimal, arrays/hash/objects/blocks/refs need their own
  * measured ABI/ownership gates. Do not silently deep-copy or borrow them. */
 return HRMV_TYPE_UNSUPPORTED;
}
hrmv_status hrmv_init(hrmv_context*c,hrmv_alloc_fn a,hrmv_free_fn f,void*u){
 if(!c||!a||!f)return HRMV_BAD_ARGUMENT;
 c->bindings=0;c->frames=0;c->user=u;c->alloc=a;c->free=f;
 c->next_frame=0;c->current_frame=0;c->live_bindings=0;c->live_frames=0;return HRMV_OK;
}
void hrmv_destroy(hrmv_context*c){
 hrmv_binding*b,*next;hrmv_frame*f,*prev;
 if(!valid(c))return;
 for(b=(hrmv_binding*)c->bindings;b;b=next){next=b->next;hrmv_value_free(c,&b->value);c->free(c->user,b,sizeof(*b));}
 for(f=(hrmv_frame*)c->frames;f;f=prev){prev=f->previous;c->free(c->user,f,sizeof(*f));}
 c->bindings=0;c->frames=0;c->current_frame=0;c->live_bindings=0;c->live_frames=0;
 /* Keep next_frame monotonic until reinitialization, rejecting stale marks. */
}
hrmv_status hrmv_frame_enter(hrmv_context*c,uint64_t*out){
 hrmv_frame*f;if(!valid(c)||!out)return HRMV_BAD_ARGUMENT;
 if(c->next_frame==UINT64_MAX)return HRMV_LIMIT;
 f=(hrmv_frame*)c->alloc(c->user,sizeof(*f));if(!f)return HRMV_MEMORY;
 f->previous=(hrmv_frame*)c->frames;f->id=c->next_frame+1;
 c->frames=f;c->next_frame=f->id;c->current_frame=f->id;c->live_frames++;*out=f->id;return HRMV_OK;
}
hrmv_status hrmv_frame_leave(hrmv_context*c,uint64_t id){
 hrmv_frame*f;hrmv_binding**link,*b,*head;
 if(!valid(c))return HRMV_BAD_ARGUMENT;
 f=(hrmv_frame*)c->frames;if(!id||!f||f->id!=id)return HRMV_BAD_FRAME;
 head=(hrmv_binding*)c->bindings;link=&head;
 while((b=*link)!=0){
  if(b->owner==id){*link=b->next;hrmv_value_free(c,&b->value);c->free(c->user,b,sizeof(*b));c->live_bindings--;}
  else link=&b->next;
 }
 c->bindings=head;
 c->frames=f->previous;c->current_frame=f->previous?f->previous->id:0;
 c->free(c->user,f,sizeof(*f));c->live_frames--;return HRMV_OK;
}
static hrmv_status make(hrmv_context*c,const char*key,uint64_t owner,hrv_cell value){
 hrmv_binding*b=(hrmv_binding*)c->alloc(c->user,sizeof(*b));
 if(!b)return HRMV_MEMORY;
 copy_name(b->name,key);b->owner=owner;b->value=value;b->next=(hrmv_binding*)c->bindings;
 c->bindings=b;c->live_bindings++;return HRMV_OK;
}
hrmv_status hrmv_declare_public(hrmv_context*c,const char*p,size_t n){
 char key[HRMV_NAME_MAX+1];hrmv_status s;hrv_cell v={HRV_LOGICAL,0};
 if(!valid(c))return HRMV_BAD_ARGUMENT;
 s=name_key(p,n,key);if(s)return s;
 if(find(c,key))return HRMV_OK;
 if(same(key,"HARBOUR")||same(key,"CLIPPER"))v.payload=1;
 return make(c,key,0,v);
}
hrmv_status hrmv_declare_private(hrmv_context*c,const char*p,size_t n){
 char key[HRMV_NAME_MAX+1];hrmv_status s;hrmv_binding*b;
 if(!valid(c))return HRMV_BAD_ARGUMENT;
 if(!c->current_frame)return HRMV_BAD_FRAME;
 s=name_key(p,n,key);if(s)return s;
 b=find(c,key);if(b&&b->owner==c->current_frame)return HRMV_OK;
 return make(c,key,c->current_frame,nil());
}
hrmv_status hrmv_get_copy(hrmv_context*c,const char*p,size_t n,hrv_cell*out){
 char key[HRMV_NAME_MAX+1];hrmv_status s;hrmv_binding*b;
 if(!valid(c)||!out)return HRMV_BAD_ARGUMENT;
 s=name_key(p,n,key);if(s)return s;
 b=find(c,key);if(!b)return HRMV_UNDEFINED;
 return value_copy(c,b->value,out);
}
hrmv_status hrmv_put_copy(hrmv_context*c,const char*p,size_t n,hrv_cell v){
 char key[HRMV_NAME_MAX+1];hrmv_status s;hrmv_binding*b;hrv_cell fresh;
 if(!valid(c))return HRMV_BAD_ARGUMENT;
 s=name_key(p,n,key);if(s)return s;
 b=find(c,key);if(!b&&!c->current_frame)return HRMV_BAD_FRAME;
 s=value_copy(c,v,&fresh);if(s)return s;
 if(b){hrv_cell old=b->value;b->value=fresh;hrmv_value_free(c,&old);return HRMV_OK;}
 s=make(c,key,c->current_frame,fresh);if(s)hrmv_value_free(c,&fresh);return s;
}
hrmv_status hrmv_exists(hrmv_context*c,const char*p,size_t n,int*out){
 char key[HRMV_NAME_MAX+1];hrmv_status s;
 if(!valid(c)||!out)return HRMV_BAD_ARGUMENT;
 s=name_key(p,n,key);if(s)return s;
 *out=find(c,key)!=0;return HRMV_OK;
}
hrmv_status hrmv_release_name(hrmv_context*c,const char*p,size_t n){
 char key[HRMV_NAME_MAX+1];hrmv_status s;hrmv_binding**link,*b,*head;
 if(!valid(c))return HRMV_BAD_ARGUMENT;
 s=name_key(p,n,key);if(s)return s;
 head=(hrmv_binding*)c->bindings;link=&head;
 while((b=*link)!=0){
  if(same(b->name,key)){
   if(b->owner)hrmv_value_free(c,&b->value);
   else{*link=b->next;hrmv_value_free(c,&b->value);c->free(c->user,b,sizeof(*b));c->live_bindings--;}
   c->bindings=head;return HRMV_OK;
  }
  link=&b->next;
 }
 return HRMV_OK;
}
