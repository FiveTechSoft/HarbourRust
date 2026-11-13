procedure main()
    local a := {}
    local x := 0
    AAdd(a, {1, 2})
    ASize(a, 2)
    for each x in a[2]
        ? x
    next
    ? "fin"
return
