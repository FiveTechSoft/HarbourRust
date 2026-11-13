// The read copy outlives the array: k is reassigned (its strings freed)
// and s - an independent owned copy - is still usable (parent contract:
// no dangling pointer after the source array is gone).
function wrap()
    local h := {=>}
    h["x"] := 5
    local k := hb_HKeys(h)
    local s := k[1]
    k := hb_HKeys(h)
    ? s
    ? h[s]
    s := k[1]
    ? s
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
