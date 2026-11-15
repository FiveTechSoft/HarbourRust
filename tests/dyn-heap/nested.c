#include "hbhbr.h"
extern HB_ULONG hbc_ext_argc,hbc_ext_ret_tag,hbc_ext_ret_pay;
extern const HB_ULONG *hbc_ext_argv;
HB_FUNC(DYN_INNER) { hb_retnd(6.25); }
HB_FUNC(DYN_OUTER) {
 HB_EVALINFO info; PHB_ITEM retained,r,scratch;
 HB_ULONG argc=hbc_ext_argc,rt,rp;const HB_ULONG *argv=hbc_ext_argv;
 retained=hb_param(2,HB_IT_ANY); scratch=hb_param(3,HB_IT_ANY);
 hb_retnd(9.75);rt=hbc_ext_ret_tag;rp=hbc_ext_ret_pay;
 if(!hb_evalNew(&info,hb_param(1,HB_IT_BLOCK))) {hb_retni(-1);return;}
 r=hb_evalLaunch(&info);
 if(argc!=hbc_ext_argc) hb_retni(-1);
 else if(argv!=hbc_ext_argv) hb_retni(-2);
 else if(rt!=hbc_ext_ret_tag) hb_retni(-3);
 else if(rp!=hbc_ext_ret_pay) hb_retni(-4);
 else if(hb_itemGetND(retained)!=2.5) hb_retni(-5);
 else if(hb_itemGetNL(scratch)!=17) hb_retni(-6);
 else if(hb_parnd(2)!=2.5) hb_retni(-7);
 else if(hb_itemGetNL(r)!=33) hb_retni(-8);
 else hb_retnd(hb_parnd(2)+hb_itemGetNL(scratch));
 hb_itemRelease(r);hb_evalRelease(&info);
}
