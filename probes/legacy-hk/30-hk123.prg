function main()
    local a := Array(2, 2, 2, 2)
    local x
    for each x in a[1, 2]
        x[1] := 7
    next
    for each x in a[1, 2]
        ? x[1]
    next
return nil
