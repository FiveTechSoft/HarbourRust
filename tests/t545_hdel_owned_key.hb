// t545: hb_HDel with an OWNED key temporary (an hb_HKeys element copy,
// a genuine StrOwn) is freed right after the delete - the leak found
// in iteration 53 (same pattern as the hb_HHasKey leak of the 52) is
// fixed; the entry is deleted and the balance returns to 0 (wrap +
// memcheck, own ownership check; not a Harbour oracle).
function wrap()
    local h := {"a" => 1, "bb" => 2}
    local ks := hb_HKeys(h)
    hb_HDel(h, ks[1])
    ? len(h)
    return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
