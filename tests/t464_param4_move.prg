function consume(p)
    ? len(p)
    ? len(p[1, 2, 1])
    p[1, 2, 1, 1] := 42
    ? p[1, 2, 1, 1]
return 0
function work()
    local a := Array(2, 2, 2, 2)
    ? consume(a)
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
