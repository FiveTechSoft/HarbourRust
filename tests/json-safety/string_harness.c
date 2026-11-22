#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "../../runtime/hrjson.c"
static void *blocks[4096];
static hrt_u64 sizes[4096];
static unsigned live;
void *hbc_alloc(hrt_u64 n) {
    void *p = malloc(n); assert(p && live < 4096);
    memset(p, 0xA5, n); blocks[live] = p; sizes[live++] = n; return p;
}
static void release_exact(void *p, hrt_u64 n) {
    unsigned i; for (i=0;i<live;i++) if(blocks[i]==p) break;
    assert(i < live && sizes[i] == n);
    free(p); blocks[i]=blocks[--live]; sizes[i]=sizes[live];
}
void hbc_freestr(char *p) { release_exact(p-16, ((hrt_u64 *)p)[-2]+16); }
void hbc_free(void *p, hrt_u64 n) { release_exact((char *)p-8, ((hrt_u64 *)p)[-1]*n+8); }
char *hbc_dtos(hrt_i64 x) { (void)x; abort(); }
char *hbc_str_f64(double x, hrt_u64 a, hrt_i64 b, hrt_i64 c, hrt_u32 d) { (void)x;(void)a;(void)b;(void)c;(void)d;abort(); }
void hbc_type_error(void) { abort(); }
static void decode(const char *json,const char *expected,hrt_u64 n) {
    struct hrt_pair p=hbc_json_decode(json,strlen(json));
    assert(p.tag==4);
    char *s=(char *)p.payload;
    assert(((hrt_u64 *)s)[-1]==n && ((hrt_u64 *)s)[-2]>=n);
    assert(!memcmp(s,expected,n)); hbc_freestr(s); assert(!live);
}
static void invalid(const char *json) {
    struct hrt_pair p=hbc_json_decode(json,strlen(json));
    assert(p.tag==1 && !live);
}
int main(void) {
    decode("\"\"","",0); decode("\"abc\"","abc",3);
    decode("\"\\u0041\"","A",1); decode("\"\\u0041Z\"","AZ",2);
    decode("\"\\u00e9\"","\xc3\xa9",2);
    decode("\"\\ud83d\\ude00Z\"","\xf0\x9f\x98\x80Z",5);
    decode("\"\\n\\t\\b\\f\\r\\/\\\\\\\"\"","\n\t\b\f\r/\\\"",8);
    invalid("\"\\ud800\""); invalid("\"\\udc00\""); invalid("\"x\ny\"");
    invalid("\"\\u004x\""); invalid("\"unterminated");
    char input[8192],expected[2048]; unsigned n=0;
    input[n++]='"';
    for(unsigned i=0;i<1000;i++) { input[n++]='\\';input[n++]='n'; expected[i]='\n'; }
    input[n++]='"';input[n]=0;decode(input,expected,1000);
    n=0; input[n++]='"';
    for(unsigned i=0;i<1000;i++) { memcpy(input+n,"\\u0041",6);n+=6;expected[i]='A'; }
    input[n++]='"';input[n]=0;decode(input,expected,1000);
    memset(expected,'x',1000); expected[1000]=0;
    struct hrt_jin req={4,(hrt_i64)expected,1000};
    struct hrt_jout out=hbc_json_encode(&req,0,0);
    assert(out.len==1002 && ((hrt_u64 *)out.ptr)[-1]==1002);
    assert(((hrt_u64 *)out.ptr)[-2]>=out.len && out.ptr[0]=='"' && out.ptr[1001]=='"');
    hbc_freestr(out.ptr); assert(!live);
    puts("PASS string headers, growth, escapes, Unicode and error cleanup (allocator registry + ASan/UBSan)");
}
