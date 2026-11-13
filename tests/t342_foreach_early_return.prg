// early `return` from inside the body: the borrowed hidden slots are never freed and the collection is owned by the frame (no leak, harness-checked).
function probe()
    local a := {}
    local x := 0
    AAdd(a, 5)
    AAdd(a, 2)
    for each x in a
        if x = 2
            return 7
        endif
    next
return 0
function main()
    ? probe()
return nil
