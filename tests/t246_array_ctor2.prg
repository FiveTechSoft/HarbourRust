function main()
    // Oracle avar: variable dimensions, nested write, nested read.
    local n := 2
    local m := 3
    local a := Array(n, m)
    ? len(a)
    ? len(a[1])
    a[2][3] := 9
    ? a[2][3]
    ? a[1][1]
return
