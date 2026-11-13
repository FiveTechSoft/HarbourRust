function d1()
    ? "dim-1"
return 2
function d2()
    ? "dim-2"
return 3
function d3()
    ? "dim-3"
return 1
function work()
    local a := Array(d1(), d2(), d3())
    ? len(a)
    ? len(a[1])
    ? len(a[1][1])
return 0
function main()
    ? work()
    ? hb_memcheck()
return
