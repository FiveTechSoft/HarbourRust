function growit(x)
    AAdd(x, {9, 8})
return 0
function work()
    local a := {{{1, 2}, {3}}, {{4}}}
    ? growit(a[1])
    ? len(a[1])
    ? len(a[1][3])
    ? a[1][3][2]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
