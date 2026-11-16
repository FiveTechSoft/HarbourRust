#define main unused_b1_main
#include "../ownership-bridge/bridge-client.c"
#undef main
#include "../../../runtime/hrmacro.h"
#include <setjmp.h>
#include <math.h>
static pool raw_pool,compiler_pool;
static hrmacro_context ctx;
static jmp_buf terminal;
static char diagnostic[512];
static unsigned fatal_count;
static unsigned fault_kind,fault_step;
static void faults(void);
static void m2(void);
static void n1(void);
static void p1(void);
unsigned char*hrm_alloc(size_t n){hrv_cell v;unsigned char*s=malloc(n?n:1);assert(s);memset(s,0,n);hrmv_status rc=strcopy(&compiler_pool,s,n,&v);free(s);return rc?0:(unsigned char*)(uintptr_t)v.payload;}
void hrm_free(unsigned char*p){if(p){uint64_t*base=(uint64_t*)p-2;block*b=compiler_pool.head;while(b&&b->p!=base)b=b->next;assert(b);hrv_cell v={b->n==32?(HR_DYN_FLOAT_HEAP|5):4,(uint64_t)(uintptr_t)p};drop(&compiler_pool,v);}}
double hrm_exp(double x){return exp(x);}
double hrm_log(double x){return log(x);}
static void fatal(void*u,const unsigned char*s,size_t n){(void)u;assert(raw_pool.live==0&&compiler_pool.live==0&&ctx.scratch_live==0);assert(!ctx.bridge.storage.live_frames&&!ctx.bridge.storage.live_bindings);assert(n<sizeof diagnostic);memcpy(diagnostic,s,n);diagnostic[n]=0;fatal_count++;longjmp(terminal,1);}
static void init(void){uint64_t frame;OK(hrmacro_init(&ctx,alloc,release,&raw_pool,strcopy,floating,&compiler_pool,fatal,0));OK(hrmb_frame_enter(&ctx.bridge,&frame));hrv_cell v={9,10};OK(hrmb_declare_put(&ctx.bridge,1,"v",1,v));hrv_cell text;OK(strcopy(&compiler_pool,(const unsigned char*)"owned",5,&text));OK(hrmb_declare_put(&ctx.bridge,1,"s",1,text));drop(&compiler_pool,text);}
static hrv_cell run(const char*s){return hrmacro_eval(&ctx,(const unsigned char*)s,strlen(s));}
static void number_value(const char*s,uint64_t tag,uint64_t value){hrv_cell v=run(s);assert(v.tag==tag&&v.payload==value);}
static void failure(const char*s,const char*message){init();if(!setjmp(terminal)){run(s);assert(!"expected fatal");}assert(!strcmp(diagnostic,message));}
int main(void){
#ifdef _WIN32
assert(_setmode(_fileno(stdout),_O_BINARY)!=-1);
#endif
init();number_value("10/2",9,5);hrv_cell v=run("v/2");check_heap(v,UINT64_C(0x4014000000000000),655362);drop(&compiler_pool,v);
number_value(".F. .AND. missing",3,0);number_value("missing .AND. .F.",3,0);number_value(".T. .OR. missing",3,1);number_value("missing .OR. .T.",3,1);assert(ctx.lookups==1);puts("parse.fold.no_elided_lookup=PASS");
v=run("&('v/2')");check_heap(v,UINT64_C(0x4014000000000000),655362);drop(&compiler_pool,v);number_value("M->v",0,10);puts("runtime.provenance.nested.memvar=PASS");
hrv_cell f;OK(floating(&compiler_pool,UINT64_C(0x400c000000000000),655364,&f));OK(hrmb_declare_put(&ctx.bridge,1,"f",1,f));drop(&compiler_pool,f);f=run("f");check_heap(f,UINT64_C(0x400c000000000000),655364);drop(&compiler_pool,f);
hrmacro_destroy(&ctx);assert(!raw_pool.live&&!compiler_pool.live);
failure("s+' temp'+missing","Error BASE/1003  Variable does not exist: MISSING\n");
failure("('owned'+' temp') + missing + later","Error BASE/1003  Variable does not exist: MISSING\n");
failure("left + ('owned'+' temp') + right","Error BASE/1003  Variable does not exist: LEFT\n");puts("fatal.order.raw_compiler_arena_zero_before_callback=PASS");
failure("missing + )","Error BASE/1449  Syntax error: &\n");assert(ctx.lookups==0);failure("M->absent","Error BASE/1003  Variable does not exist: ABSENT\n");puts("parse.syntax_before_lookup.deferred_first_error=PASS");
assert(fatal_count==5&&raw_pool.count==raw_pool.freed&&compiler_pool.count==compiler_pool.freed);puts("raw.compiler.frames.bindings.scratch=0");faults();m2();n1();p1();return 0;}
void*hrm_raw_alloc(void*u,size_t n){return alloc(u?u:&raw_pool,n);}
void hrm_raw_free(void*u,void*p,size_t n){release(u?u:&raw_pool,p,n);}
hrmv_status hrm_export_string(void*u,const unsigned char*s,size_t n,hrv_cell*out){return strcopy(u?u:&compiler_pool,s,n,out);}
hrmv_status hrm_export_float(void*u,uint64_t bits,uint64_t meta,hrv_cell*out){return floating(u?u:&compiler_pool,bits,meta,out);}
void hrm_fail(const unsigned char*s,size_t n){fatal(0,s,n);abort();}

static void faults(void){
 for(fault_kind=0;fault_kind<2;fault_kind++)for(fault_step=1;fault_step<=48;fault_step++){
  init();pool*p=fault_kind?&compiler_pool:&raw_pool;p->fail=p->attempt+fault_step;
  if(!setjmp(terminal)){
   hrv_cell v=run("(s+' temp')+'!' ");drop(&compiler_pool,v);hrmacro_destroy(&ctx);
  }
  raw_pool.fail=compiler_pool.fail=0;
  assert(!raw_pool.live&&!compiler_pool.live&&!ctx.scratch_live);
  assert(raw_pool.count==raw_pool.freed&&compiler_pool.count==compiler_pool.freed);
 }
 puts("fault.raw.compiler.48_steps_each.cleanup_before_fatal=PASS");
}

void hrm_builtin_fail(const unsigned char*s,size_t n,const unsigned char*b,size_t z){(void)b;(void)z;fatal(0,s,n);}

double hrm_fmod(double x,double y){return fmod(x,y);}
double hrm_powf(double x,double y){return pow(x,y);}
/* Native host dispatch only: allocation/argument-lifetime proof, not production
 * formatter/rounding proof. PRG gates execute the actual assembly helpers. */
unsigned hrm_call(unsigned id,size_t argc,const hrm_cell*argv,hrm_cell*out){
 (void)argc;
 if(id==1||id==2){
  const unsigned char*s=(const unsigned char*)(uintptr_t)argv[0].payload;size_t n=((const uint64_t*)s)[-1];unsigned char*p=hrm_alloc(n);if(!p)return 0;
  for(size_t i=0;i<n;i++){unsigned char c=s[i];p[i]=id==1?(c>='a'&&c<='z'?c-32:c):(c>='A'&&c<='Z'?c+32:c);}
  *out=(hrm_cell){4,(uint64_t)(uintptr_t)p};return 1;
 }
 if(id==3){double v=(argv[0].tag&255)==5?*(double*)(uintptr_t)argv[0].payload:(double)(int64_t)argv[0].payload;
  int d=(int)((argv[1].tag&255)==5?*(double*)(uintptr_t)argv[1].payload:(double)(int64_t)argv[1].payload);double scale=pow(10,d);union{double d;uint64_t u;}bits;bits.d=round(v*scale)/scale;
  return floating(&compiler_pool,bits.u,((uint64_t)10<<16)|(d>0?d:0),out)==HRMV_OK;
 }
 return 0;
}

static void m2(void){
 init();hrv_cell v=run("Upper(Lower(s))");assert(v.tag==4&&!memcmp((void*)(uintptr_t)v.payload,"OWNED",5));drop(&compiler_pool,v);
 size_t before=ctx.lookups;v=run("Upper('literal',missing)");assert(ctx.lookups==before&&v.tag==4);drop(&compiler_pool,v);
 hrmacro_destroy(&ctx);
 failure("Upper(s,1,2,3,4,5,6,7,8,missing)","Error BASE/1003  Variable does not exist: MISSING\n");
 failure("Upper(missing)+)","Error BASE/1449  Syntax error: &\n");assert(ctx.lookups==0);
 failure("Upper(1)","Error BASE/1102  Argument error: UPPER\n");
 failure("Round(v,16)","Error: macro ROUND decimals outside -15..15 (M2)\n");
 for(fault_kind=0;fault_kind<2;fault_kind++)for(fault_step=1;fault_step<=96;fault_step++){
  init();pool*p=fault_kind?&compiler_pool:&raw_pool;p->fail=p->attempt+fault_step;
  if(!setjmp(terminal)){v=run("Upper(Lower(s+' suffix'),Round(v/3,2))");drop(&compiler_pool,v);hrmacro_destroy(&ctx);}
  raw_pool.fail=compiler_pool.fail=0;assert(!raw_pool.live&&!compiler_pool.live&&!ctx.scratch_live);assert(raw_pool.count==raw_pool.freed&&compiler_pool.count==compiler_pool.freed);
 }
 puts("M2.args.nested.fold.extras10.syntax.types.range.faults96x2.cleanup=PASS");
}

/* N1 checks exact parser classification independently of large-float Str width. */
static void n1(void){
 init();char text[64];
 for(int64_t offset=0;offset<=80;offset++){
  int64_t want=INT64_MAX-offset;snprintf(text,sizeof text,"%lld",(long long)want);hrv_cell v=run(text);assert(v.tag==9&&(int64_t)v.payload==want);
  snprintf(text,sizeof text,"-%lld",(long long)want);v=run(text);assert(v.tag==9&&(int64_t)v.payload==-want);
 }
 hrv_cell v=run("9223372036854775808");check_heap(v,UINT64_C(0x43e0000000000000),655360);drop(&compiler_pool,v);
 v=run("-9223372036854775808");check_heap(v,UINT64_C(0xc3e0000000000000),655360);drop(&compiler_pool,v);
 hrmacro_destroy(&ctx);assert(!raw_pool.live&&!compiler_pool.live);puts("N1.exact_i64_boundaries.overflow_double.cleanup=PASS");
}

static void p1(void){
 init();char text[64];size_t before;
 for(unsigned j=0;j<1000;j++){
  strcpy(text,(j&1)?"v+2":"v+1");hrv_cell r=run(text);assert(r.payload==(j&1?12:11));
  r=run("Upper(&('s'))+Lower(&('s'))");assert(r.tag==4&&!memcmp((void*)(uintptr_t)r.payload,"OWNEDowned",10));drop(&compiler_pool,r);
 }
 before=raw_pool.attempt;for(unsigned j=0;j<1000;j++){hrv_cell r=run("Upper(s)");drop(&compiler_pool,r);}assert(raw_pool.attempt==before);
 assert(ctx.raw_pool.retained<=262144&&ctx.scratch_live==0);hrmacro_destroy(&ctx);hrmacro_destroy(&ctx);assert(!raw_pool.live&&!compiler_pool.live&&!ctx.raw_pool.all&&!ctx.raw_pool.retained);
 failure("Upper(&('s+missing'))","Error BASE/1003  Variable does not exist: MISSING\n");
 assert(!ctx.raw_pool.all&&!ctx.raw_pool.retained&&!ctx.raw_pool.live_blocks&&!ctx.raw_pool.live_bytes);puts("P1.reuse.text_mutation.nested.outer_lifetime.no_new_backing.destroy_twice.fatal_flush=PASS");
}
