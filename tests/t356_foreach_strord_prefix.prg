// prefix rule in ordering: comparison bounded by the right operand's length (oracle hk40).
function main()
    local a := {}
    local c := ""
    AAdd(a, "abc")
    AAdd(a, "a")
    AAdd(a, "abcd")
    AAdd(a, "abc")
    for each c in a
        if c < "abc"
            ? "menor"
        endif
        if c > "abc"
            ? "mayor"
        endif
        if c <= "abc"
            ? "menorigual"
        endif
        if c >= "abc"
            ? "mayorigual"
        endif
    next
return nil
