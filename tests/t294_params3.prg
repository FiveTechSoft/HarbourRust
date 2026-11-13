function consume(p)
    ? len(p)
    ? len(p[1])
    ? p[1][1][2]
    p[1][1][2] := 99
    ? p[1][1][2]
return 0
function work()
    local a := {{{1, 2}}, {{3}}}
    ? consume(a)
return 0
function main()
    ? work()
    ? hb_memcheck()
return
