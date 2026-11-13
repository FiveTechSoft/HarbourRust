function work()
    local b := {7, 8}
    local a := {{{1}}}
    AAdd(a[1], b)
    ? a[1][2][2]
    ? b[2]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
