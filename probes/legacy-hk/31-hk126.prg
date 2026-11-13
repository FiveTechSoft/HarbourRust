function main()
    local a := Array(2)
    local b := Array(2)
    a[1] := 5
    b[1] := 5
    ? a == a
    ? a == b
    ? b == b
return nil
