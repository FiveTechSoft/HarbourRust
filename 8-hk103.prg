function main()
    local a := Array(2, 2, 2, 2)
    ? len(a)
    ? len(a[1])
    ? len(a[1,2])
    ? len(a[1,2,1])
    ? a[1,2,1,2]
    a[1,2,1,2] := 99
    ? a[1,2,1,2]
    ? a[2,1,2,1]
    ? valtype(a[1,2,1])
    ? valtype(a[1,2,1,1])
return nil
