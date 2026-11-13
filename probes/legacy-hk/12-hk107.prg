function main()
    local a := Array(2, 2, 2, 2)
    a[1][2][1][2] := 5
    ? a[1][2][1][2]
    ? len(a[2][1][2])
return nil
