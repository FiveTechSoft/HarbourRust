// t534: hb_HSet on a non-hash target is a clean compile error.
function main()
    local a := {1, 2}
    hb_HSet(a, "x", 1)
return nil
