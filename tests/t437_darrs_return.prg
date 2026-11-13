function mk()
    local a := {}
    AAdd(a, "uno")
    AAdd(a, "dos")
return a
function work()
    local b := mk()
    ? len(b)
    ? b[2]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
