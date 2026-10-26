// t564: owned key temporaries (hb_HKeys(h)[i] element copies) through
// the insensitive compare path of hb_HHasKey and hb_HDel, a miss on an
// empty flagged hash, and full balance including the header-only
// block's free - wrap + memcheck = 0 pattern (own ownership check,
// same pattern as t298; not a Harbour oracle).
function wrap()
    local h := {"a" => 1, "A" => 2}
    local ks := hb_HKeys(h)
    local e := {=>}
    hb_HSetCaseMatch(h, 0)
    hb_HSetCaseMatch(e, 0)
    ? hb_HHasKey(h, ks[1])
    hb_HDel(h, ks[2])
    ? len(h)
    ? hb_HHasKey(e, "zz")
    return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
