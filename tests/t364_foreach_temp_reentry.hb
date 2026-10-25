// a temporary collection freed on statement re-entry (enclosing loop) and at the epilogue: balance 0.
function mk()
    local a := {}
    AAdd(a, 7)
return a
function run()
    local x := 0
    local i := 1
    while i <= 3
        for each x in mk()
            ? x
        next
        i := i + 1
    enddo
return i
function main()
    ? run()
    ? hb_memcheck()
return nil
