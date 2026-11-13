#include "hbhbr.h"
HB_FUNC(HBR_PI)   { hb_retnd(3.141592653589793); }
HB_FUNC(HBR_HALF) { hb_retnd(hb_parnd(1) / 2); }
HB_FUNC(HBR_INFO) { hb_retnl((long) hb_parinfo(1)); }
HB_FUNC(HBR_TRUNC){ hb_retnl(hb_parnl(1)); }
HB_FUNC(HBR_ISNUMQ){ hb_retl(HB_ISNUM(1)); }
