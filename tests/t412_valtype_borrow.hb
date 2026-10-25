function vt(p)
    ? ValType(p)
    ? ValType(p[1])
return 0
function wrap()
    local b := {{1, 2}, {3}}
    ? vt(b[1])
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
