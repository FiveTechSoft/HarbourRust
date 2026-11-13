// middle shrink frees the removed innermost children.
function work()
    local a := {{{1, 2}, {3}}}
    ASize(a[1], 1)
    ? len(a[1])
    ? a[1][1][1]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
