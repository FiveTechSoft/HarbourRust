// t524: hb_HDel on a non-hash variable is a clean compile error.
function main()
    local a := {1, 2}
    hb_HDel(a, "x")
return nil
