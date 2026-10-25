// AAdd on the middle with a static literal: materializes as a dynamic child (hk66).
function work()
    local a := {{{1, 2}}}
    local x := 0
    AAdd(a[1], {5, 6})
    ? len(a[1])
    for each x in a[1][2]
        ? x
    next
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
