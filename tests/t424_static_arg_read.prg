function showit(x)
    ? len(x)
    ? x[2]
return 0
function work()
    local a := {1, 2, 3}
    ? showit(a)
    ? len(a)
    ? a[3]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
