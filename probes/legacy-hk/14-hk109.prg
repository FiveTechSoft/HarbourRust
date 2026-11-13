function main()
    local a := Array(2, 2, 2, 2)
    local x
    a[1, 2, 1, 1] := 7
    a[1, 2, 1, 2] := 8
    for each x in a[1, 2, 1]
        ? x
    next
    ? len(a[1, 2, 1])
    ? len(a)
    ? a[1, 2, 1, 1]
return nil
