// t592: hb_HSetDef(h, key, def) - present same tag keeps the stored
// value, absent adds key=def (hk196; 1/0 is the registered boolean
// rendering family).
function main()
    local h := {"a" => 1}
    ? hb_HSetDef(h, "a", 7)
    ? h["a"]
    ? hb_HSetDef(h, "b", 5)
    ? len(h)
    ? hb_HHasKey(h, "b")
    ? hb_HSetDef(h, "b", 8)
    ? h["b"]
return nil
