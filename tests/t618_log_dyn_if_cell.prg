// t618: a bare logical casilla is a valid condition (Harbour: IF accepts
// any expression and a logical cell branches on its payload)
function main()
    local a := {}
    aadd( a, .T. )
    aadd( a, .F. )
    if a[1]
        ? "si"
    endif
    if a[2]
        ? "no"
    else
        ? "no2"
    endif
    while a[1]
        ? "giro"
        a[1] := .F.
    enddo
return nil
