function growit(x)
    AAdd(x, 7)
    ? len(x)
    ? x[4]
return 0
function work()
    local a := {1, 2, 3}
    ? growit(a)
    ? len(a)
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
