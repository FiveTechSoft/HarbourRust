// hb_HKeys: case-sensitive keys, overwrite keeps position (oracle hk5).
function wrap()
    local h := {=>}
    h["one"] := 1
    h["one"] := 9
    h["ONE"] := 7
    local k := hb_HKeys(h)
    ? len(k)
    ? k[1]
    ? h[k[1]]
    ? k[2]
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
