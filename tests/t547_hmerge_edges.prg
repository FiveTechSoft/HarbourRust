// t547: hb_HMerge edges (hk165): merging into an EMPTY target copies
// the entries; the SOURCE is not mutated (it keeps its entries and
// values); an empty source is a no-op. Both arguments are hash
// VARIABLES in this PoC surface (the inline empty-literal form of
// hk165 is a named surface limit, not a semantic difference).
function main()
    local d := {=>}
    local s := {"a" => 1}
    hb_HMerge(d, s)
    ? len(d)
    ? d["a"]
    ? len(s)
    ? s["a"]
    local e := {=>}
    hb_HMerge(d, e)
    ? len(d)
return nil
