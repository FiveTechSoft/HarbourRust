function work()
    local b := {1, 2}
    local a := {{9}}
    AAdd(a, b)
    ? len(a)
    ? a[2][1]
    ? b[1]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
