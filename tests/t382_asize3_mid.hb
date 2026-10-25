// ASize on the middle a[i]: grow with NIL casillas (hk65); existing children survive.
function work()
    local a := {{{1, 2}}}
    local x := 0
    ASize(a[1], 3)
    ? len(a)
    ? len(a[1])
    ? len(a[1][1])
    for each x in a[1][1]
        ? x
    next
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
