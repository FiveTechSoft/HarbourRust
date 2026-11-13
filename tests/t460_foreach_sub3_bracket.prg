function work()
    local a := Array(2, 2, 2, 2)
    local x := 0
    a[1, 2, 1, 1] := 7
    a[1, 2, 1, 2] := 8
    for each x in a[1][2][1]
        ? x
    next
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
