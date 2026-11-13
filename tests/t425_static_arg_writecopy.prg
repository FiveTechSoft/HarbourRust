function setit(x)
    x[1] := 99
    ? x[1]
return 0
function work()
    local a := {1, 2, 3}
    ? setit(a)
    ? a[1]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
