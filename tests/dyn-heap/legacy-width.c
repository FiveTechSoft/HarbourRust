#include "hbhbr.h"
extern HB_ULONG hbc_ext_argc;
extern const HB_ULONG *hbc_ext_argv;
HB_FUNC(LEGACY_WIDTH) {
 union { double d; HB_ULONG u; } v;
 HB_ULONG cell[2],count=hbc_ext_argc;
 const HB_ULONG *argv=hbc_ext_argv;
 PHB_ITEM item;
 v.d=hb_parnd(1);cell[0]=5;cell[1]=v.u;
 hbc_ext_argv=cell;hbc_ext_argc=1|(count&0x100000000ULL);
 item=hb_itemNew(hb_param(1,HB_IT_ANY));
 hbc_ext_argv=argv;hbc_ext_argc=count;
 hb_itemReturn(item);hb_itemRelease(item);
}
