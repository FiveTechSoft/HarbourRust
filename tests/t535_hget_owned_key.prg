// t535: hb_HGet with an OWNED key temporary (an hb_HKeys element copy,
// a genuine StrOwn): the lookup borrows it and it is freed right after
// hbc_hget returns, with and without the integer default (wrap +
// memcheck = 0, own ownership check, same pattern as t298; not a
// Harbour oracle). The default keeps being evaluated and discarded
// (hk158f1/f2).
function wrap()
    local h := {"a" => 5, "bb" => 2}
    local ks := hb_HKeys(h)
    ? hb_HGet(h, ks[1])
    ? hb_HGet(h, ks[1], 9)
    return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
