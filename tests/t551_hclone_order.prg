// t551: hb_HClone preserves insertion order and NIL values, and an
// empty hash clones to an empty one (hk167).
function main()
    local h := {"a" => 1, "n" => NIL, "c" => 3}
    local c := hb_HClone(h)
    local e := {=>}
    local ce := hb_HClone(e)
    ? hb_HPos(c, "a")
    ? hb_HPos(c, "n")
    ? hb_HPos(c, "c")
    ? c["n"]
    ? len(ce)
return nil
