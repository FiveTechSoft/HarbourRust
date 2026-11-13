// AAdd on the middle with a VARIABLE: the move contract of root AAdd extends here -
// the source is nulled (Harbour would SHARE: registered difference D5/D7, pending decision).
function work()
    local a := {{{1, 2}}}
    local b := {}
    local x := 0
    AAdd(b, 7)
    AAdd(b, 8)
    AAdd(a[1], b)
    ? len(a[1])
    for each x in a[1][2]
        ? x
    next
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
