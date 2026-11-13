function showit(x)
    ? len(x)
    ? x[1]
    ? x[2]
return 0
function wrap()
    local a := {{1, 2}, {3, 4}}
    ? showit(a[1])
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
