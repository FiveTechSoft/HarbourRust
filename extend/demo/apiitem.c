#include "hbhbr.h"
HB_FUNC(HBR_MKNUM)  { PHB_ITEM p = hb_itemNew(0); hb_itemPutND(p, 2.5); hb_itemReturn(p); hb_itemRelease(p); }
HB_FUNC(HBR_MKSTR)  { PHB_ITEM p = hb_itemNew(0); hb_itemPutC(p, "built in C"); hb_itemReturn(p); hb_itemRelease(p); }
HB_FUNC(HBR_ECHO)   { PHB_ITEM a = hb_param(1, HB_IT_ANY); PHB_ITEM p = hb_itemNew(a); hb_itemReturn(p); hb_itemRelease(p); }
HB_FUNC(HBR_TY)     { PHB_ITEM p = hb_itemNew(0); long t; hb_itemPutC(p, "x"); t = (long) hb_itemType(p); hb_itemRelease(p); hb_retnl(t); }
HB_FUNC(HBR_GETC)   { PHB_ITEM a = hb_param(1, HB_IT_STRING); char * s; long n; if (!a) { hb_retc("notstr"); return; } s = hb_itemGetC(a); n = (long) hb_itemGetCLen(a); hb_retclen(s, (HB_SIZE) n); hb_xfree(s); }
HB_FUNC(HBR_NILIT)  { PHB_ITEM p = hb_itemNew(0); hb_itemReturn(p); hb_itemRelease(p); }

HB_FUNC(HBR_KEEP) {
    /* Oracle pin (694428e): hb_itemReturn COPIES - the item keeps its
     * value afterwards ("kept", not NIL, not moved out). */
    PHB_ITEM p = hb_itemNew(0);
    char * s; int ok;
    hb_itemPutC(p, "kept");
    hb_itemReturn(p);
    s = hb_itemGetC(p);
    ok = s && s[0] == 'k' && s[1] == 'e' && s[2] == 'p' && s[3] == 't' && s[4] == 0;
    hb_xfree(s);
    hb_itemRelease(p);
    hb_retl(ok);
}

HB_FUNC(HBR_COPYC) {
    /* Oracle pin (694428e): hb_itemCopyC(item, buf, 2) on "abc" copies
     * exactly 2 bytes, NO terminator, returns 2. */
    PHB_ITEM a = hb_param(1, HB_IT_STRING);
    char buf[8]; HB_SIZE n;
    buf[0] = 'X'; buf[1] = 'X'; buf[2] = 'X'; buf[3] = 0;
    n = a ? hb_itemCopyC(a, buf, 2) : 0;
    hb_retl(n == 2 && buf[0] == 'a' && buf[1] == 'b' && buf[2] == 'X');
}

HB_FUNC(HBR_GETCEMPTY) {
    /* Oracle pin (694428e): hb_itemGetC("") non-NULL, hb_itemGetC(NIL) NULL. */
    PHB_ITEM p = hb_itemNew(0);
    char * s; int ok;
    hb_itemPutC(p, "");
    s = hb_itemGetC(p);
    ok = s != 0 && s[0] == 0;
    hb_xfree(s);
    ok = ok && hb_itemGetC(hb_itemNew(0)) == 0;
    hb_itemRelease(p);
    hb_retl(ok);
}

HB_FUNC(HBR_LOOPRET) {
    /* 2.1 review probe: itemNew + PutC + itemReturn + itemRelease must
     * not grow memory (the item keeps its value; Release frees it). */
    long i;
    for (i = 0; i < 20000; i++) {
        PHB_ITEM p = hb_itemNew(0);
        hb_itemPutC(p, "loop-return-probe");
        hb_itemReturn(p);
        hb_itemRelease(p);
    }
    hb_retl(1);
}
