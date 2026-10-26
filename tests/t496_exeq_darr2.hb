// t496: `==` on two nested dynamic array VARIABLES is reference
// identity (oracle hk130: a==a .T., a==b .F. even with equal
// contents). The frame slot's first qword IS the identity.
function main()
    local a := Array(2, 2)
    local b := Array(2, 2)
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
