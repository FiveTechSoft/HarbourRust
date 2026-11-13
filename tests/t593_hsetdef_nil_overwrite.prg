// t593: hb_HSetDef - stored NIL + integer default OVERWRITES (tag
// differs, hk196b); absent key with no default adds NIL.
function main()
    local h := {"a" => NIL}
    ? hb_HSetDef(h, "a", 5)
    ? h["a"]
    ? hb_HSetDef(h, "b")
    ? len(h)
    ? hb_HHasKey(h, "b")
    ? h["b"]
return nil
