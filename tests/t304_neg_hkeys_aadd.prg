// AAdd with a non-string element onto an array of strings is a named
// compile error (string elements are legal since iteration 29 - t307).
function main()
    local h := {=>}
    h["a"] := 1
    local k := hb_HKeys(h)
    AAdd(k, 7)
return nil
