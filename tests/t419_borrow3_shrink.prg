function shrinkit(x)
    ? len(x[1])
    ASize(x, 1)
return 0
function work()
    local a := {{{1, 2}, {3}}, {{4}}}
    ? shrinkit(a[1])
    ? len(a[1])
    ? len(a)
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
