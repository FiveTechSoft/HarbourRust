function mk()
    local a := {{{1, 2}}, {{3}}}
return a
function wrap()
    local a := {{{1, 2}}, {{3}}}
    ? len(a)
return 0
function use()
    local v := mk()
    ? len(v)
return 0
function main()
    ? wrap()
    ? use()
    ? hb_memcheck()
return
