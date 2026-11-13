// t519: hb_HValues on an empty hash is an empty array; an earlier
// snapshot does not see later growth (oracle hk154: 0/0/1/7/7).
function main()
    local h := {=>}
    local v := hb_HValues(h)
    local w := {}
    local k := 0
    ? len(v)
    h["x"] := 7
    ? len(v)
    w := hb_HValues(h)
    ? len(w)
    ? w[1]
    for each k in w
        ? k
    next
return nil
