// t561: insensitive hb_HPos answers the position of the LAST match and
// hb_HDel removes that entry (the "a" survivor keeps its casing)
// (oracle hk174).
function main()
    local h := {"a" => 1, "A" => 2}
    local ks := hb_HKeys(h)
    hb_HSetCaseMatch(h, 0)
    ? hb_HPos(h, "a")
    hb_HDel(h, "a")
    ? len(h)
    ks := hb_HKeys(h)
    ? ks[1]
return nil
