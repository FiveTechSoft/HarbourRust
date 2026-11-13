// ASize on a {} array grown with strings: same size is a no-op, shrink
// frees copies, shrink to 0 frees the rest; balance 0 after work() exits.
function work()
    local k := {}
    AAdd(k, "a")
    AAdd(k, "bb")
    AAdd(k, "ccc")
    ASize(k, 3)
    ? len(k)
    ASize(k, 1)
    ? len(k)
    ? k[1]
    ASize(k, 0)
    ? len(k)
return 0
function main()
    local r := work()
    ? hb_memcheck()
return nil
