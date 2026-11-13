#include "hbhbr.h"

/* Milestone 2.4 probe: Dyn-held arrays cross read-only. Canonical
 * Harbour pattern: hb_param(i, HB_IT_ARRAY) + hb_arrayGet* readers. */

HB_FUNC(HBR_ARRLEN) { hb_retnl((long) hb_arrayLen(hb_param(1, HB_IT_ARRAY))); }

HB_FUNC(HBR_ARRSUM) {
    PHB_ITEM a = hb_param(1, HB_IT_ARRAY);
    long s = 0; HB_SIZE i, n = hb_arrayLen(a);
    for (i = 1; i <= n; i++) s += hb_arrayGetNL(a, i);
    hb_retnl(s);
}

HB_FUNC(HBR_ARRTYPES) {
    /* ValType letters of the elements, via hb_arrayGetType */
    PHB_ITEM a = hb_param(1, HB_IT_ARRAY);
    static char buf[64]; HB_SIZE i, n = hb_arrayLen(a);
    for (i = 1; i <= n && i < 60; i++) {
        HB_TYPE t = hb_arrayGetType(a, i);
        buf[i-1] = t == HB_IT_ARRAY ? 'A' : t == HB_IT_STRING ? 'C' :
                   t == HB_IT_LOGICAL ? 'L' : (t & HB_IT_NUMERIC) ? 'N' : 'U';
    }
    buf[n < 60 ? n : 59] = 0;
    hb_retc(buf);
}

HB_FUNC(HBR_ARRGETPTR) {
    /* flat read through hb_arrayGetItemPtr on the hb_param handle */
    PHB_ITEM a = hb_param(1, HB_IT_ARRAY);
    long s = 0; HB_SIZE i, n = hb_arrayLen(a);
    for (i = 1; i <= n; i++) s += hb_itemGetNL(hb_arrayGetItemPtr(a, i));
    hb_retnl(s * 100 + (long) n);
}

HB_FUNC(HBR_ARROOB) {
    PHB_ITEM a = hb_param(1, HB_IT_ARRAY);
    hb_retl(hb_arrayGetItemPtr(a, 0) == 0 && hb_arrayGetItemPtr(a, 99) == 0 &&
            hb_arrayGetType(a, 99) == HB_IT_NIL);
}

HB_FUNC(HBR_ARRNONARR) {
    hb_retl(hb_arrayLen(hb_param(1, HB_IT_ANY)) == 0 && hb_parinfa(1, 0) == 0);
}

HB_FUNC(HBR_ARRREFSUM) {
    /* @array: the canonical pattern reads through the byref hop */
    PHB_ITEM a = hb_param(1, HB_IT_ARRAY);
    long s = 0; HB_SIZE i, n = hb_arrayLen(a);
    for (i = 1; i <= n; i++) s += hb_arrayGetNL(a, i);
    hb_retnl(s);
}

HB_FUNC(HBR_ARRINFA) {
    /* hb_parinfa: 0 -> length, n -> element HB_IT_* type */
    hb_retnl((long) hb_parinfa(1, 0) * 100000 + (long) hb_parinfa(1, 2));
}

HB_FUNC(HBR_ARRINFO) { hb_retnl((long) hb_parinfo(1)); }
HB_FUNC(HBR_ARRPARAMARR) { hb_retl(hb_param(1, HB_IT_ARRAY) != 0 && hb_param(1, HB_IT_STRING) == 0); }
HB_FUNC(HBR_ISARRQ) { hb_retl(HB_ISARRAY(1)); }
