function main()
    local a := Array(2, 2, 2, 2)
    local x := 7
    for each x in a[1, 2]
        exit
    next
    ? x
    for each x in a[1, 2]
        ? ValType(x)
    next
    ? x
return nil
