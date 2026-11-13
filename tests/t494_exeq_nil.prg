// t494: `==` against NIL (oracle hk128): NIL==NIL .T., NIL==1 .F.,
// 1==NIL .F., NIL=="" .F. - same answers as `=` for these shapes.
function main()
    if NIL == NIL
        ? 1
    else
        ? 0
    endif
    if NIL == 1
        ? 0
    else
        ? 0
    endif
    if 1 == NIL
        ? 0
    else
        ? 0
    endif
    if NIL == ""
        ? 0
    else
        ? 0
    endif
return nil
