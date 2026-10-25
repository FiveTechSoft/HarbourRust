function work()
    local a := Array(2, 2, 2, 2)
    AAdd(a[1][2][1], 8)
    ? len(a[1, 2, 1])
    ? a[1, 2, 1, 3]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
