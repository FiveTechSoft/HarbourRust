// t525: hb_HHasKey(h, k) - byte-exact, case-sensitive membership,
// answered .T./.F. (hk157), matching Harbour's logical render.
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
