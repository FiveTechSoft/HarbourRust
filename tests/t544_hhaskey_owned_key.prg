// t544: hb_HHasKey with an OWNED key temporary (an hb_HKeys element
// copy, a genuine StrOwn) is freed right after the lookup - the leak
// found in iteration 52 (an element-copy key was never released) is
// fixed; wrap + memcheck = 0 (own ownership check, same pattern as
// t298/t533; not a Harbour oracle).
function wrap()
    local h := {"a" => 1, "bb" => 2}
    local ks := hb_HKeys(h)
    ? hb_HHasKey(h, ks[2])
    ? hb_HHasKey(h, ks[1])
    return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
