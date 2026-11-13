function make()
    local a := Array(3, 0)
    local z := Array(0, 3)
    if a[1] = NIL
        ? "MAL fila nil"
    else
        ? "fila vacia no nil"
    endif
    ? len(a)
    ? len(z)
return 0
function main()
    local v := make()
    ? v
    ? hb_memcheck()
return
