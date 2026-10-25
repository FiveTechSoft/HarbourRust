// hb_HKeys of an empty hash: a zero-length array (oracle hk6).
function wrap()
    local h := {=>}
    local k := hb_HKeys(h)
    ? len(k)
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
