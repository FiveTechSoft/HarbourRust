// AAdd on the middle with a dynamic call result (hk69).
function work()
    local a := {{{1, 2}}}
    AAdd(a[1], Array(2))
    ? len(a[1])
    ? len(a[1][2])
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
