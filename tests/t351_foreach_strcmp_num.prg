// numeric element against a string: Harbour raises BASE/1071 (hk34, dialog hangs headless) - clean named exit 1.
function main()
    local a := {}
    local x := 0
    AAdd(a, 1)
    for each x in a
        if x = "a"
            ? "igual"
        endif
    next
return nil
