function main()
    local a := {{1, 2}, {3}}
    local x := 0
    ? ValType(a)
    ? ValType(a[1])
    ? ValType(a[1][1])
    ? ValType(7)
    ? ValType("s")
    ? ValType(NIL)
    x := NIL
    ? ValType(x)
    x := 9
    ? ValType(x)
return nil
