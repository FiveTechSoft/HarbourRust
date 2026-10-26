// t580: hb_HDelAt removes the entry at a 1-based position, positions
// compact, and deleting the only entry empties the hash
// (hk187/hk190).
function main()
    local h := {"a" => 1, "b" => 2, "c" => 3}
    local e := {"solo" => 9}
    hb_HDelAt(h, 1)
    ? len(h)
    ? hb_HKeyAt(h, 1)
    hb_HDelAt(h, 2)
    ? len(h)
    ? hb_HKeyAt(h, 1)
    hb_HDelAt(e, 1)
    ? len(e)
return nil
