procedure main()
    local a := {{1, 2}, {3, 4}}
    local x := 0
    for each x in a[1]
        x := x * 10
    next
    ? a[1][1], a[1][2]
return
