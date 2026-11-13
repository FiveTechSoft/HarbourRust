// numeric casilla ordered against a string: Harbour raises BASE/1073 (hk42, dialog hangs headless) - clean named exit 1.
function main()
    local a := {}
    local x := 0
    AAdd(a, 1)
    for each x in a
        if x < "a"
            ? "menor"
        endif
    next
return nil
