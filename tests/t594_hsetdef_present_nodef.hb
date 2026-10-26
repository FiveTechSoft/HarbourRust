// t594: hb_HSetDef with a PRESENT key and NO default keeps the
// stored value (hk196d, measured this iteration).
function main()
    local h := {"a" => 7}
    ? hb_HSetDef(h, "a")
    ? h["a"]
    ? len(h)
return nil
