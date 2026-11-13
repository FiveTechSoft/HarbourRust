function mk()
    local a := {{{1, 2}}, {{3}}}
return a
function mid()
    local b := mk()
    ? len(b)
return b
function use()
    local v := mid()
    ? len(v)
    ? v[1][1][2]
return 0
function main()
    ? use()
    ? hb_memcheck()
return
