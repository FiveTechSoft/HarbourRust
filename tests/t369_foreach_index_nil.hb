// iterating a NIL casilla: Harbour raises BASE/1068 (hk58, dialog hangs headless) - clean named exit 1.
function main()
    local a := {{1, 2}}
    local x := 0
    ASize(a, 2)
    for each x in a[2]
        ? x
    next
return nil
