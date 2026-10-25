// alloc/free balance across a function boundary: the callee's epilogue
// frees every key copy and the block (instrumented registry verifies the
// exact sizes); hb_memcheck reads AFTER the callee returned.
function dowork()
    local h := {"a" => 1, "b" => 2, "c" => 3, "d" => 4, "e" => 5}
    for i := 1 to 20
        h["k"] := i
    next
    h["zz"] := 99
    ? len(h)
    ? h["zz"]
return nil
function main()
    local r := dowork()
    ? hb_memcheck()
return nil
