// t559: a case-variant write with two variants present overwrites the
// LAST match (the "A" entry) and keeps both entries and their original
// casing (oracle hk172).
function main()
    local h := {"a" => 1, "A" => 2}
    local ks := hb_HKeys(h)
    local vs := hb_HValues(h)
    hb_HSetCaseMatch(h, 0)
    h["a"] := 9
    ? len(h)
    ks := hb_HKeys(h)
    vs := hb_HValues(h)
    ? ks[1]
    ? vs[1]
    ? ks[2]
    ? vs[2]
return nil
