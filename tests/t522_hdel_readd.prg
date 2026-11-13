// t522: a deleted key re-added lands at the END (hk156 oracle - the
// remaining entries keep their order); deleting "" is a no-op. The
// oracle's interleaved h[k] read with a Dyn for-each var is a named
// limit of this increment (reads take Str/StrOwn keys), so the values
// are read back through literal keys after the loop.
function main()
    local h := {"a" => 1, "bb" => 2, "c" => 3}
    local k := ""
    hb_HDel(h, "bb")
    h["bb"] := 22
    ? len(h)
    for each k in hb_HKeys(h)
        ? k
    next
    ? h["a"]
    ? h["c"]
    ? h["bb"]
    hb_HDel(h, "")
    ? len(h)
return nil
