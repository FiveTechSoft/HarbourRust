#ifdef HRBRIDGE
#include "hbhbr.h"
#else
#include "hbapi.h"
#include "hbapiitm.h"
#endif
/* Own test extension. Borrow at entry, bridge/oracle return channel clones. */
HB_FUNC(HBR_ECHO){hb_itemReturn(hb_param(1,HB_IT_ANY));}
