// NIL casilla ordered against a string: Harbour raises BASE/1075 (hk47, dialog hangs headless) - clean named exit 1.
function main()
    local h := {"a" => 1}
    local k := hb_HKeys(h)
    local c := ""
    ASize(k, 2)
    for each c in k
        if c > "a"
            ? "mayor"
        endif
    next
return nil
