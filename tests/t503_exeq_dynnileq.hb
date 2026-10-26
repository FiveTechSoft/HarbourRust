// t503: `==` with NIL casillas: NIL x NIL is .T., NIL x payload is
// .F. (oracle hk140: .T./.F./.F.).
function main()
    local a := Array(2)
    local b := Array(2)
    if a[1] == b[1]
        ? 1
    else
        ? 0
    endif
    if a[1] == "hola"
        ? 1
    else
        ? 0
    endif
    if a[1] == 7
        ? 1
    else
        ? 0
    endif
return nil
