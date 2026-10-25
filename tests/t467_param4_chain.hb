function inner(p)
    p[2, 1, 2, 1] := 9
    ? p[2, 1, 2, 1]
return 0
function outer(p)
    ? inner(p)
return 0
function work()
    local a := Array(2, 2, 2, 2)
    ? outer(a)
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
