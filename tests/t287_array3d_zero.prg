function work()
    local a := Array(0, 2, 3)
    local b := Array(2, 0, 3)
    local c := Array(2, 3, 0)
    ? len(a)
    ? len(b)
    ? len(b[1])
    if b[1] = NIL
        ? 1
    else
        ? 0
    endif
    ? len(c)
    ? len(c[1])
    ? len(c[1][1])
return 0
function main()
    ? work()
    ? hb_memcheck()
return
