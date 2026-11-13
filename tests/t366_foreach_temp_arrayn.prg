// Array(n) temporary: the created NIL casillas iterate as NIL.
function run()
    local x := 0
    for each x in Array(2)
        if x = NIL
            ? "nil"
        endif
    next
return 1
function main()
    ? run()
    ? hb_memcheck()
return nil
