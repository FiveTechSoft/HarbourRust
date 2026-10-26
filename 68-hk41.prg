procedure main()
    local a
    local c := ""
    a := {}
    AAdd(a, "b")
    AAdd(a, NIL)
    a[2] := NIL
    for each c in a
        ? c < "b", c > "b"
    next
return
