// t535: hb_HGet with an OWNED key temporary (function-returned string):
// the lookup borrows it and it is freed right after hbc_hget returns,
// with and without the integer default (wrap + memcheck = 0, own
// ownership check, same pattern as t298/t533; not a Harbour oracle).
// The default keeps being evaluated and discarded (hk158f1/f2).
function kf()
    return "a"
function wrap()
    local h := {"a" => 5}
    ? hb_HGet(h, kf())
    ? hb_HGet(h, kf(), 9)
    return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
