// neg: inline `:=` through a by-reference parameter is not in this
// increment (the store-through-pointer contract in expression position
// is not oracle-pinned).
function f(p)
    ? ( p := 5, p )
    return nil
function main()
    local x := 0
    f(@x)
    return nil
