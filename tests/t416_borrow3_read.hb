function showit(x)
    ? len(x)
    ? len(x[1])
    ? x[1][1]
return 0
function work()
    local a := {{{1, 2}, {3}}, {{4}}}
    ? showit(a[1])
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
