function mk()
    local a := {1, 2, 3}
return a
function work()
    local b := mk()
    ASize(b, 1)
    ? len(b)
    ? b[1]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
