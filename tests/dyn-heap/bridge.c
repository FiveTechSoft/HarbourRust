/* Host C API checkpoint; hbc allocation helpers stubbed with tracked libc
 * blocks. Full freestanding ELF/PE gates remain required separately. */
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "hbhbr.h"
extern HB_ULONG hbc_ext_argc,hbc_ext_ret_tag,hbc_ext_ret_pay;
extern const HB_ULONG *hbc_ext_argv;
extern void hbc_ext_end(void);
#define HEAP (((HB_ULONG)1)<<63)
#define CAP (((HB_ULONG)1)<<32)
static int live,inner_heap;
void *hbc_strcpy(const void *p,HB_ULONG n) {
    HB_ULONG *q=malloc(16+n);assert(q);q[0]=n;q[1]=n;
    memcpy(q+2,p,n);live++;return q+2;
}
void hbc_freestr(void *p) {assert(p);live--;assert(live>=0);free((HB_ULONG*)p-2);}
static HB_ULONG bits(double d) {union{double d;HB_ULONG b;}u;u.d=d;return u.b;}
static void clear_ret(void) {
    if((hbc_ext_ret_tag&255)==4 || ((hbc_ext_ret_tag&255)==5&&(hbc_ext_ret_tag&HEAP))) hbc_freestr((void*)hbc_ext_ret_pay);
    hbc_ext_ret_tag=1;hbc_ext_ret_pay=0;
}
/* Callback mock checks the same outer/inner global-channel interaction,
 * not the assembly block ABI (covered by the later freestanding gate). */
HB_LONG test_blk_launch(HB_LONG code,const HB_ULONG *vals,HB_LONG count) {
    HB_ULONG inner[4]={4,0,5,0};(void)code;(void)vals;assert(count==0);
    inner[3]=bits(9.5);inner[1]=(HB_ULONG)hbc_strcpy("inner",5);hbc_ext_argc=2|(inner_heap?CAP:0);hbc_ext_argv=inner;
    assert(hb_parnd(1)==9.5);hb_retnd(4.5);clear_ret();
    assert(strcmp(hb_parc(2),"inner")==0);hbc_ext_end();hbc_freestr((void*)inner[1]);return 77;
}
int main(void) {
    int mode,format,inner;
    for(mode=0;mode<2;mode++)for(format=0;format<2;format++)for(inner=0;inner<2;inner++) {
        HB_ULONG f[2]={5,0},argv[8],ref[2]={1,0};PHB_ITEM p,q,block;HB_EVALINFO ev;
        HB_ULONG data[2]={0,((HB_ULONG)10<<16)|1};data[0]=bits(2.5);f[1]=data[0];
        if(format){f[0]=HEAP|5;f[1]=(HB_ULONG)hbc_strcpy(data,16);}
        /* Reversed slots: float1, string2, byref3, block4. */
        argv[6]=f[0];argv[7]=f[1];
        argv[4]=4;argv[5]=(HB_ULONG)hbc_strcpy("outer",5);
        argv[2]=10;argv[3]=(HB_ULONG)ref;argv[0]=7;argv[1]=1;
        hbc_ext_argc=4|(mode?CAP:0);hbc_ext_argv=argv;
        assert(hb_pcount()==4&&hb_parinfo(0)==4&&hb_param(5,HB_IT_ANY)==0);
        {int was=live;assert(!hb_stornd(9.5,0));assert(!hb_stornd(9.5,1));assert(!hb_stornd(9.5,99));assert(live==was); }
        assert(hb_parnd(1)==2.5&&hb_parnl(1)==2&&hb_parinfo(1)==HB_IT_DOUBLE);
        p=hb_itemNew(hb_param(1,HB_IT_ANY));q=hb_itemNew(p);
        assert(hb_itemGetND(p)==2.5&&hb_itemGetND(q)==2.5);
        hb_itemReturn(p);assert(((hbc_ext_ret_tag&HEAP)!=0)==mode);clear_ret();
        hb_itemPutND(p,-3.5);assert(hb_itemGetND(q)==2.5&&hb_itemGetND(p)==-3.5);
        assert(hb_stornd(6.5,3));assert(((ref[0]&HEAP)!=0)==mode);
        assert(hb_parnd(3)==6.5);assert(hb_storni(6,3));
        hb_itemRelease(p);hb_itemRelease(q);
        {
            const char *outer=hb_parc(2);assert(strcmp(outer,"outer")==0);
            HB_ULONG before_argc=hbc_ext_argc;const HB_ULONG *before_argv=hbc_ext_argv;
            hb_retnd(8.5);HB_ULONG rt=hbc_ext_ret_tag,rp=hbc_ext_ret_pay;
            block=hb_itemNew(hb_param(4,HB_IT_ANY));assert(hb_evalNew(&ev,block));
            inner_heap=inner;p=hb_evalLaunch(&ev);assert(hb_itemGetNL(p)==77);hb_itemRelease(p);hb_evalRelease(&ev);
            assert(hbc_ext_argc==before_argc&&hbc_ext_argv==before_argv);
            assert(hbc_ext_ret_tag==rt&&hbc_ext_ret_pay==rp);
            assert(hb_parnd(1)==2.5&&hb_parnl(3)==6&&strcmp(outer,"outer")==0);
            clear_ret();hbc_ext_end();
        }
        if(format) {hbc_freestr((void*)f[1]);}
        hbc_freestr((void*)argv[5]);assert(live==0);
    }
    return 0;
}
