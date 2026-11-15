/* Uses exact production hbc_float_new/unpack/str_f64, not fake formatting. */
#define main fake_pool_regression_main
#include "../tests/bridge-client.c"
#undef main
extern hrv_cell __attribute__((sysv_abi)) hrbt_new(uint64_t,uint64_t);
extern hrv_cell __attribute__((sysv_abi)) hrbt_string(const unsigned char*,size_t);
extern unsigned char* __attribute__((sysv_abi)) hrbt_format(uint64_t,uint64_t);
extern void __attribute__((sysv_abi)) hrbt_free(void*);
extern uint64_t __attribute__((sysv_abi)) hrbt_balance(void);
extern uint64_t __attribute__((sysv_abi)) hrbt_unpack_meta(uint64_t,uint64_t);
extern void __attribute__((sysv_abi)) hrbt_flush(void);
hrmv_status real_float(void*u,uint64_t bits,uint64_t meta,hrv_cell*out){(void)u;*out=hrbt_new(bits,meta);return HRMV_OK;}
static hrmv_status real_string(void*u,const unsigned char*s,size_t n,hrv_cell*out){(void)u;*out=hrbt_string(s,n);return HRMV_OK;}
static void emit(const char*label,hrv_cell v,const char*expected){unsigned char*s=hrbt_format(v.tag,v.payload);size_t n=(size_t)((uint64_t*)s)[-1];if(n!=strlen(expected)||memcmp(s,expected,n)){fprintf(stderr,"actual n=%zu expected=%zu [%.*s]\n",n,strlen(expected),(int)n,s);abort();}printf("%s=[",label);fwrite(s,1,n,stdout);puts("]");hrbt_free(s);hrbt_free((void*)(uintptr_t)v.payload);}
extern uint64_t __attribute__((sysv_abi)) hrbt_abi_gate(void*);
extern uint64_t __attribute__((sysv_abi)) hrbt_parity_gate(void);
extern hrmv_status hrbt_native_probe(void*,uint64_t,uint64_t,hrv_cell*);
extern uint64_t hrbt_bad_alignment;
int main(void){pool raw={0};hrmb_context c;uint64_t frame;hrv_cell v,out;block*b;
#ifdef _WIN32
assert(_setmode(_fileno(stdout),_O_BINARY)!=-1);
#endif
assert(hrbt_abi_gate((void*)hrbt_native_probe)==0&&hrbt_bad_alignment==0);
assert(hrbt_parity_gate()==0);puts("ABI.native.SysV.sentinels.parities=PASS");
OK(hrmb_init(&c,alloc,release,&raw,real_string,real_float,0));OK(hrmb_frame_enter(&c,&frame));
v=hrbt_new(UINT64_C(0x400c000000000000),(10u<<16)|4u);OK(hrmb_declare_put(&c,1,"heap",4,v));hrbt_free((void*)(uintptr_t)v.payload);OK(hrmb_get_copy(&c,"HEAP",4,&out));for(b=raw.head;b;b=b->next)assert((uint64_t)(uintptr_t)b->p!=out.payload);emit("heap.dec4",out,"         3.5000");
v=hrbt_new(UINT64_C(0x4014000000000000),(10u<<16)|2u);OK(hrmv_put_copy(&c.storage,"heap",4,v));hrbt_free((void*)(uintptr_t)v.payload);OK(hrmb_get_copy(&c,"heap",4,&out));emit("heap.anchor",out,"         5.00");
v.tag=5;v.payload=UINT64_C(0x4014000000000000);OK(hrmb_declare_put(&c,1,"inline",6,v));OK(hrmb_get_copy(&c,"INLINE",6,&out));emit("legacy.dec0.default2",out,"         5.00");
v.tag=5|(4u<<8);v.payload=UINT64_C(0x400c000000000000);OK(hrmv_put_copy(&c.storage,"inline",6,v));OK(hrmb_get_copy(&c,"inline",6,&out));emit("legacy.dec4",out,"         3.5000");
{
 const uint64_t boundaries[]={0,UINT64_C(0x8000000000000000),UINT64_C(0x4202a05f1ff80000),UINT64_C(0x4202a05f1ff80001),UINT64_C(0x4202a05f20000000),UINT64_C(0xc1cdcd64ff800000),UINT64_C(0xc1cdcd64ff800001)};
 for(size_t i=0;i<sizeof(boundaries)/sizeof(boundaries[0]);i++)for(unsigned dec=0;dec<=255;dec++){
  v.tag=5|((uint64_t)dec<<8);v.payload=boundaries[i];uint64_t expected=hrbt_unpack_meta(v.tag,v.payload);
  OK(hrmv_put_copy(&c.storage,"inline",6,v));OK(hrmb_get_copy(&c,"inline",6,&out));if(hrbt_unpack_meta(out.tag,out.payload)!=expected){fprintf(stderr,"decoder mismatch bits=%llx dec=%u expected=%llx actual=%llx\n",(unsigned long long)v.payload,dec,(unsigned long long)expected,(unsigned long long)hrbt_unpack_meta(out.tag,out.payload));abort();}hrbt_free((void*)(uintptr_t)out.payload);
 }
 puts("legacy.decoder.thresholds.meta=PASS");
}
v=hrbt_string((const unsigned char*)"owned",5);OK(hrmb_declare_put(&c,1,"text",4,v));hrbt_free((void*)(uintptr_t)v.payload);OK(hrmb_get_copy(&c,"TEXT",4,&out));assert(out.tag==4&&((uint64_t*)(uintptr_t)out.payload)[-1]==5&&!memcmp((void*)(uintptr_t)out.payload,"owned",5));puts("string.heap=[owned]");hrbt_free((void*)(uintptr_t)out.payload);
OK(hrmb_frame_leave(&c,frame));assert(!c.storage.live_frames&&!c.storage.live_bindings);hrmb_destroy(&c);assert(!raw.live&&raw.count==raw.freed);assert(hrbt_balance()==0);hrbt_flush();assert(hrbt_balance()==0);puts("raw.real_compiler.live=0");return 0;}
