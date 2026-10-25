function shrinkit(x)
    ASize(x, 1)
return 0
function wrap()
    local a := {{1, 2}, {3, 4}}
    ? shrinkit(a[1])
    ? len(a[1])
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
