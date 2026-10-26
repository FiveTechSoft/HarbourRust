// t505: `==` on hash VARIABLES is reference identity (oracle hk134:
// h==h .T., h==k .F. even with equal contents). The frame slot's
// first qword is the heap pointer - the identity.
function main()
    local h := {"a" => 1}
    local h2 := {"a" => 1}
    if h == h
        ? 1
    else
        ? 0
    endif
    if h == h2
        ? 0
    else
        ? 0
    endif
    if h2 == h2
        ? 1
    else
        ? 0
    endif
return nil
