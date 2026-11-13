// several Dyn-string comparisons together and nested - unique labels per emission (oracle hk51).
function main()
    local a := {}
    local c := ""
    AAdd(a, "abc")
    AAdd(a, "ab")
    AAdd(a, "abd")
    AAdd(a, "b")
    for each c in a
        if "ab" < c
            if c <= "ab"
                ? "menor-e-igual"
            else
                ? "menor"
            endif
        else
            if "ab" >= c
                ? "igual"
            else
                ? "mayor"
            endif
        endif
    next
    for each c in a
        if c = "ab"
            ? "igual-ab"
        endif
        if c >= "ab"
            if c > "ab"
                ? "mayor-ab"
            endif
        endif
    next
return nil
