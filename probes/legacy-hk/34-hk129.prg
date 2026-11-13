function main()
    local a := Array(2, 2)
    ? a[1] == NIL
    ? NIL == a[1]
    ? a[1][1] == NIL
    a[1][1] := 4
    ? a[1][1] == NIL
    ? a[1] == NIL
return nil
