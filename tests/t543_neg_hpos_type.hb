// t543: hb_HPos on a non-hash target is a clean compile error.
function main()
    local a := {1, 2}
    ? hb_HPos(a, "x")
return nil
