#include "hbhbr.h"
HB_FUNC(HBR_BUMP)  { hb_stornl(hb_parnl(1) + 1, 1); }
HB_FUNC(HBR_SETS)  { hb_storc("stored", 1); }
HB_FUNC(HBR_SETD)  { hb_stornd(hb_parnd(1) * 2, 1); }
HB_FUNC(HBR_SETL)  { hb_storl(!hb_parl(1), 1); }
HB_FUNC(HBR_ISREF) { hb_retl(HB_ISBYREF(1)); }
HB_FUNC(HBR_INFO2) { hb_retnl((long) hb_parinfo(1)); }
HB_FUNC(HBR_STORC_RC) { hb_retni(hb_storc("x", 1)); }
