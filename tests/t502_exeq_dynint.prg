// t502: `==` on numeric casillas compares by value, both directions
// (oracle hk138: .T./.F./.T./.T.).
function main()
    local a := Array(2)
    local b := Array(2)
    a[1] := 1
    b[1] := 1
    if a[1] == b[1]
        ? 1
    else
        ? 0
    endif
    if a[1] == 2
        ? 1
    else
        ? 0
    endif
    if 1 == a[1]
        ? 1
    else
        ? 0
    endif
    if a[1] == a[1]
        ? 1
    else
        ? 0
    endif
return nil
