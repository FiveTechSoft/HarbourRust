function mk()
    local a := Array(2, 2, 2, 2)
    a[2, 1, 2, 1] := 9
return a
function work()
    local b := mk()
    ? len(b)
    ? len(b[2, 1, 2])
    ? b[2, 1, 2, 1]
    ? b[1, 1, 1, 1]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
