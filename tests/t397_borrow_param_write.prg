function setit(x)
    x[1] := 99
return 0
function wrap()
    local a := {{1, 2}, {3, 4}}
    ? setit(a[1])
    ? a[1][1]
    ? len(a[1])
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
