function mk()
    local a := {1, 2, 3}
return a
function work()
    local b := mk()
    ? len(b)
    ? b[1]
    ? b[2]
    ? b[3]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
