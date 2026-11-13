function wrap()
    local h := {=>}
    h["beta"] := 1
    h["Alpha"] := 2
    h["gamma"] := 3
    local k := hb_HKeys(h)
    local s := k[1]
    ? s
    ? h[s]
    h[s] := 42
    ? h["beta"]
    h[k[2]] := 7
    ? h["Alpha"]
    s := k[3]
    ? s
    ? len(k)
    k := hb_HKeys(h)
    ? len(k)
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
