// t542: hb_HPos with an OWNED key temporary (an hb_HKeys element copy,
// a genuine StrOwn): the lookup borrows it and it is freed right after
// hbc_hpos returns (wrap + memcheck = 0, own ownership check, same
// pattern as t298; not a Harbour oracle).
function wrap()
    local h := {"a" => 1, "bb" => 2}
    local ks := hb_HKeys(h)
    ? hb_HPos(h, ks[2])
    return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
