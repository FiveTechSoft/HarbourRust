// t525: hb_HHasKey(h, k) - byte-exact, case-sensitive membership,
// answered 1/0 (hk157 oracle prints .T./.F.; the dialect has no
// logical type, so 1/0 is the PoC surface - the registered boolean
// rendering family).
function main()
    local h := {"a" => 1, "bb" => 2}
    ? hb_HHasKey(h, "a")
    ? hb_HHasKey(h, "bb")
    ? hb_HHasKey(h, "zz")
    ? hb_HHasKey(h, "A")
    ? hb_HHasKey(h, "b")
    ? hb_HHasKey(h, "")
    h[""] := 9
    ? hb_HHasKey(h, "")
    hb_HDel(h, "a")
    ? hb_HHasKey(h, "a")
return nil
