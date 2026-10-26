function main()
    local a := Array(2, 2, 2, 2)
    local x, y
    for each x in a[1, 2]
        for each y in a[1, 1]
            y[1] := 4
        next
        x[1] := 3
    next
    ? a[1, 1, 1, 1]
    ? a[1, 2, 1, 1]
    ? a[2, 1, 1, 1]
return nil
