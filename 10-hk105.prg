function main()
    local a := Array(2, 2, 2, 2)
    a[1,2,1,1] := 7
    ? len(a[1,2,1])
    AAdd(a[1,2,1], 8)
    ? len(a[1,2,1])
    ? a[1,2,1,3]
    ASize(a[1,2,1], 1)
    ? len(a[1,2,1])
    ? a[1,2,1,1]
return nil
