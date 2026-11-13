function growit(x)
    AAdd(x, 9)
return 0
function wrap()
    local a := {{1, 2}, {3, 4}}
    ? growit(a[1])
    ? len(a[1])
    ? a[1][3]
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
