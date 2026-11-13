function consume(a)
    AAdd(a[1], 9)
    ? len(a[1])
return 0
function mk()
    local r := {{1, 2}, {3, 4}}
return r
function wrap()
    local v := {{1, 2}, {3, 4}}
    local c := consume(v)
    local w := mk()
    ? len(w)
return 0
function main()
    local r := wrap()
    ? r
    ? hb_memcheck()
return
