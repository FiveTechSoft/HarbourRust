// An owned string RETURNED by a function moves to the caller (the
// callee's slot is nulled before its epilogue) and the caller frees it.
function give()
    local h := {=>}
    h["x"] := 1
    local k := hb_HKeys(h)
    local s := k[1]
    k := hb_HKeys(h)
    ? s
return s
function wrap()
    local r := give()
    ? r
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
