function setit(x)
    x[1][2] := 42
return 0
function work()
    local a := {{{1, 2}, {3}}, {{4}}}
    ? setit(a[1])
    ? a[1][1][2]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
