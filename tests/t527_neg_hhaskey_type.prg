// t527: hb_HHasKey on a non-hash target is a clean compile error.
function main()
    local a := {1, 2}
    ? hb_HHasKey(a, "x")
return nil
