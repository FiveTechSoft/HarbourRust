// Grow then shrink: the grown NIL casillas own nothing and the shrink
// frees the live copies; balance 0 after work() exits.
function work()
    local k := {}
    AAdd(k, "a")
    ASize(k, 4)
    ASize(k, 1)
    ? len(k)
    ? k[1]
return 0
function main()
    local r := work()
    ? hb_memcheck()
return nil
