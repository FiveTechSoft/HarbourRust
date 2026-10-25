function inner(p)
    p[1][1][2] := 42
return 0
function outer(q)
    ? inner(q)
return 0
function work()
    local a := {{{1, 2}}, {{3}}}
    ? outer(a)
return 0
function main()
    ? work()
    ? hb_memcheck()
return
