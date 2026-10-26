// t558: with two case-variant keys "a"/"A" present, insensitive reads
// return the LAST insertion-order match for either spelling; HSet adds
// "b" and HasKey "B" matches it (oracle hk171).
function main()
    local h := {"a" => 1, "A" => 2}
    hb_HSetCaseMatch(h, 0)
    ? h["a"]
    ? h["A"]
    hb_HSet(h, "b", 5)
    ? hb_HHasKey(h, "B")
    ? len(h)
return nil
