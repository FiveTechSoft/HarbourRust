// t557: a case-variant WRITE h["A"] := 9 over the existing "a" in
// insensitive mode overwrites in place (len stays 1), the stored key
// keeps its ORIGINAL casing ("a") and re-tightening restores the miss
// (oracle hk170).
function main()
    local h := {"a" => 1}
    local ks := hb_HKeys(h)
    hb_HSetCaseMatch(h, 0)
    h["A"] := 9
    ? len(h)
    ? h["a"]
    ks := hb_HKeys(h)
    ? ks[1]
    hb_HSetCaseMatch(h, 1)
    ? hb_HHasKey(h, "A")
return nil
