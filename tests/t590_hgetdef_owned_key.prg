// t590: hb_HGetDef with an OWNED key copy (ks[i]) - the lookup borrows
// the copy and frees it right after (hk194 semantics; memcheck proves
// the balance, t298 pattern: work() computes, main checks zero).
function work()
    local h := {"a" => 1, "bb" => 2}
    local ks := hb_HKeys(h)
    ? hb_HGetDef(h, ks[2])
    ? hb_HGetDef(h, ks[1])
    ? hb_HGetDef(h, "zz", 42)
return 0
function main()
    local r := work()
    ? hb_memcheck()
return nil
