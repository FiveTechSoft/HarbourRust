// t512: string casilla `=` NIL casilla is .F. in both directions, no
// error (oracle hk147).
function main()
    local h := {"a" => 1}
    local a := {}
    AAdd(a, NIL)
    local k := hb_HKeys(h)
    local c := 0
    for each c in k
        if c = a[1]
            ? 1
        else
            ? 0
        endif
        if a[1] = c
            ? 1
        else
            ? 0
        endif
    next
return nil
