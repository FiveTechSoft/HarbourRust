// t521: hb_HDel removes a key (hk155 oracle): len drops, iteration and
// lookups skip it, a missing key is a no-op, deleting all leaves len 0.
function main()
    local h := {"a" => 1, "bb" => 2, "c" => 3}
    local k := ""
    hb_HDel(h, "bb")
    ? len(h)
    for each k in hb_HKeys(h)
        ? k
    next
    ? h["a"]
    ? h["c"]
    hb_HDel(h, "zz")
    ? len(h)
    hb_HDel(h, "a")
    hb_HDel(h, "c")
    ? len(h)
return nil
