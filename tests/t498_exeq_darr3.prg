// t498: `==` on three-level dynamic array VARIABLES is reference
// identity (oracle hk135: a==a .T., a==b .F.).
function main()
    local a := Array(2, 2, 2)
    local b := Array(2, 2, 2)
    if a == a
        ? 1
    else
        ? 0
    endif
    if a == b
        ? 0
    else
        ? 0
    endif
    if b == b
        ? 1
    else
        ? 0
    endif
return nil
