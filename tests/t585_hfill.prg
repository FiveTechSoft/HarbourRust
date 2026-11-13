// t585: hb_HFill overwrites every value (including a stored NIL),
// keeps keys, positions and count, fills with NIL, and is a no-op on
// an empty hash (hk192).
function main()
    local h := {"a" => 1, "b" => NIL, "c" => 3}
    local e := {=>}
    hb_HFill(h, 7)
    ? h["a"]
    ? h["b"]
    ? h["c"]
    ? hb_HKeyAt(h, 2)
    ? len(h)
    hb_HFill(h, NIL)
    ? h["a"]
    hb_HFill(e, 5)
    ? len(e)
return nil
