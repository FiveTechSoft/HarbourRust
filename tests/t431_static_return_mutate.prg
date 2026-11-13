function mk()
    local a := {1, 2, 3}
return a
function work()
    local b := mk()
    b[1] := 99
    ? b[1]
    AAdd(b, 7)
    ? len(b)
    ? b[4]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
