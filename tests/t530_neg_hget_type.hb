// t530: hb_HGet on a non-hash target is a clean compile error.
function main()
    local a := {1, 2}
    ? hb_HGet(a, "x")
return nil
