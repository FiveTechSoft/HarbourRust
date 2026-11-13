function mut(x)
    ? len(x)
    ? x[1]
    x[1] := "tres"
    AAdd(x, "cuatro")
    ? x[1]
    ? len(x)
return 0
function work()
    local a := {}
    AAdd(a, "uno")
    AAdd(a, "dos")
    ? mut(a)
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
