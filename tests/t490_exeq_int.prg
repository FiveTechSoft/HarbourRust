// t490: integer `==` compares like `=` (oracle hk124: 1==1 .T.,
// 1==2 .F.). Booleans are not printable in this PoC, so the truth
// pattern is encoded through if/else into 1/0.
function main()
    if 1 == 1
        ? 1
    else
        ? 0
    endif
    if 1 == 2
        ? 1
    else
        ? 0
    endif
return nil
