// grown NIL casillas iterate as NIL (oracle hk30); exit keeps the pre-loop value too (hk28).
function main()
    local a := {}
    local x := 7
    AAdd(a, 1)
    ASize(a, 3)
    for each x in a
        ? x
        if len(a) = 3
            exit
        endif
    next
    ? x
return nil
