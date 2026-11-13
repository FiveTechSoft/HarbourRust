// t533: hb_HSet evaluates KEY first, THEN the value (hk161 - the
// opposite of h[k] := v, h4); an OWNED key temporary (an hb_HKeys
// element copy, a genuine StrOwn) is freed after hbc_hput copies it
// (wrap + memcheck = 0, own ownership check, same pattern as t298;
// not a Harbour oracle).
function kf()
    ? 1
    return "bb"
function vf()
    ? 2
    return 3
function wrap()
    local h := {"a" => 1}
    hb_HSet(h, kf(), vf())
    local ks := hb_HKeys(h)
    hb_HSet(h, ks[1], 7)
    return h["bb"]
function main()
    ? wrap()
    ? hb_memcheck()
return nil
