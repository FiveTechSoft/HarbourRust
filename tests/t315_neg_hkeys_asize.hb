// ASize is not in the string-array increment: named compile error.
function main()
    local h := {=>}
    h["a"] := 1
    local k := hb_HKeys(h)
    ASize(k, 5)
return nil
