function main()
    local a := Array(2, 2, 2, 2)
    local x
    for each x in a[1, 2]
        ? ValType(x)
    next
    a[1, 2, 1, 1] := 5
    for each x in a[1, 2]
        ? x[1]
    next
return nil
