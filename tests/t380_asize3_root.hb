// ASize on a three-level root: grow with NIL casillas (hk68); shrink frees removed children recursively.
function work()
    local a := {{{1, 2}}}
    ASize(a, 3)
    ? len(a)
    ASize(a, 1)
    ? len(a)
    ? a[1][1][1]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
