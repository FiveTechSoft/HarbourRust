function work()
    local a := Array(2, 2, 2)
    AAdd(a[1, 2], 9)
    ? len(a[1][2])
    ? a[1][2][3]
    ASize(a[1, 2], 1)
    ? len(a[1][2])
    ? a[1][2][1]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
