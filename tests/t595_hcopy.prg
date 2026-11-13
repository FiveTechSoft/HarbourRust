// t595: hb_HCopy(src, dst [, start [, count]]) as a statement - slice
// and edges (hk195; the hash it returns is out of the statement
// surface, like hb_HMerge's - the oracle's ValType line is dropped,
// registered).
function main()
    local h := {"a" => 1, "b" => 2, "c" => 3}
    local d := {=>}
    local e := {"x" => 9}
    hb_HCopy(h, d, 2)
    ? len(d)
    ? hb_HKeyAt(d, 1)
    hb_HCopy(h, e, 1, 2)
    ? len(e)
    ? e["a"]
    ? e["x"]
    hb_HCopy(h, d)
    ? len(d)
return nil
