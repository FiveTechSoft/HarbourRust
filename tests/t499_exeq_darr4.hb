// t499: `==` on four-level dynamic array VARIABLES is reference
// identity (oracle hk135: c==c .T., c==d .F.).
function main()
    local c := Array(2, 2, 2, 2)
    local d := Array(2, 2, 2, 2)
    if c == c
        ? 1
    else
        ? 0
    endif
    if c == d
        ? 0
    else
        ? 0
    endif
    if d == d
        ? 1
    else
        ? 0
    endif
return nil
