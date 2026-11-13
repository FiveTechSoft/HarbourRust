function main()
    local a := Array(2, 2, 2, 2)
    ? ">"
    ? ValType(a[1])
    ? ValType(a[1, 2])
    ? ValType(a[1, 2, 1])
    ? ValType(a[1, 2, 1, 1])
    a[1, 2, 1, 1] := 5
    ? ValType(a[1, 2, 1, 1])
    ? "<"
return nil
