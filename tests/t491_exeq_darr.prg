// t491: one-level dynamic array `==` is reference identity (oracle
// hk126): a==a .T., a==b .F. even with equal contents, b==b .T.
function main()
    local a := Array(2)
    local b := Array(2)
    a[1] := 5
    b[1] := 5
    if a == a
        ? 1
    else
        ? 0
    endif
    if a == b
        ? 1
    else
        ? 0
    endif
    if b == b
        ? 1
    else
        ? 0
    endif
return nil
