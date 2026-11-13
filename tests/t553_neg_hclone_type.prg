// t553: hb_HClone on a non-hash target is a clean compile error.
function main()
    local a := {1, 2}
    local c := hb_HClone(a)
return nil
