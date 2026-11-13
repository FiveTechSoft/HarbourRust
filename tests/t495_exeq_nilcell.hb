// t495: dynamic casilla == NIL (oracle hk129): live child .F.,
// NIL==a[1] .F., NIL casilla .T., after write .F., live child still .F.
function main()
    local a := Array(2, 2)
    if a[1] == NIL
        ? 0
    else
        ? 0
    endif
    if NIL == a[1]
        ? 0
    else
        ? 0
    endif
    if a[1][1] == NIL
        ? 1
    else
        ? 0
    endif
    a[1][1] := 4
    if a[1][1] == NIL
        ? 0
    else
        ? 0
    endif
    if a[1] == NIL
        ? 0
    else
        ? 0
    endif
return nil
