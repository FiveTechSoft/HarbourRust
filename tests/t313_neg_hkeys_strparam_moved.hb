// After take(s) moves the owned string into the callee, using s is a
// compile error.
function take(s)
    if s = "x"
        return 1
    endif
return 0
function main()
    local h := {=>}
    h["x"] := 5
    local k := hb_HKeys(h)
    local s := k[1]
    ? take(s)
    ? s
return nil
