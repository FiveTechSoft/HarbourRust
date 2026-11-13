// shrinking a three-level root to zero frees everything.
function work()
    local a := {{{1, 2}}, {{3, 4}}}
    ASize(a, 0)
    ? len(a)
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
