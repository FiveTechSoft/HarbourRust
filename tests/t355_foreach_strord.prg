// Dyn (left) ordered against a string: byte-wise over the right operand's length (oracle hk39).
function main()
    local a := {}
    local c := ""
    AAdd(a, "b")
    AAdd(a, "a")
    AAdd(a, "c")
    for each c in a
        if c > "b"
            ? "mayor-b"
        endif
        if c < "b"
            ? "menor-b"
        endif
        if c <= "b"
            ? "menorigual-b"
        endif
        if c >= "b"
            ? "mayorigual-b"
        endif
    next
return nil
