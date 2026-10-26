function main()
    local a := Array(2, 2, 2, 2)
    local x
    for each x in a[1, 2]
        x[1] := 9
    next
    ? a[1, 2, 1, 1]
    ? a[1, 2, 2, 1]
    ? a[1, 1, 1, 1]
return nil
