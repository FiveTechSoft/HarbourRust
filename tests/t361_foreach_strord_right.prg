// Dyn as the RIGHT operand of the ordering (oracle hk51).
function main()
    local a := {}
    local c := ""
    AAdd(a, "abc")
    AAdd(a, "ab")
    AAdd(a, "abd")
    AAdd(a, "b")
    for each c in a
        if "b" < c
            ? "b-menor"
        endif
        if "b" > c
            ? "b-mayor"
        endif
    next
return nil
