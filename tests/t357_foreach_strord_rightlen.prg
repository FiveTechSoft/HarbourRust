// the left operand truncates to the right operand's length (oracle hk43).
function main()
    local a := {}
    local c := ""
    AAdd(a, "abc")
    AAdd(a, "ab")
    AAdd(a, "abd")
    AAdd(a, "abb")
    for each c in a
        if c < "ab"
            ? "menor"
        endif
        if c > "ab"
            ? "mayor"
        endif
        if c <= "ab"
            ? "menorigual"
        endif
        if c >= "ab"
            ? "mayorigual"
        endif
    next
return nil
