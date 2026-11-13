// numeric element <> string: Harbour raises BASE/1072 (hk38, dialog hangs headless) - clean named exit 1.
function main()
    local a := {}
    local x := 0
    AAdd(a, 1)
    for each x in a
        if x <> "a"
            ? "distinto"
        endif
    next
return nil
