function work()
    local a := Array(2, 2, 3)
    ? len(a)
    ? len(a[1])
    ? len(a[1][1])
    a[1][2][3] := 7
    ? a[1][2][3]
    if a[2][1][1] = NIL
        ? 1
    else
        ? 0
    endif
    if a[1][1][1] = NIL
        ? 1
    else
        ? 0
    endif
return 0
function main()
    ? work()
    ? hb_memcheck()
return
