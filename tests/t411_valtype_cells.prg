function work()
    local a := {}
    local c := {}
    AAdd(a, "s")
    ? ValType(a[1])
    ASize(a, 2)
    ? ValType(a[2])
    AAdd(c, 7)
    ? ValType(c[1])
    ASize(c, 2)
    ? ValType(c[2])
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
