// After grow(k) moves the array into the callee, using k is a compile
// error (the value lives in the callee now).
function grow(p)
    AAdd(p, "two")
return p
function main()
    local h := {=>}
    h["one"] := 1
    local k := hb_HKeys(h)
    local g := grow(k)
    ? len(k)
return nil
