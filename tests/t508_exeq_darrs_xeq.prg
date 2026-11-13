// t508: on the expressible string-array surface ({} + AAdd, DArrS),
// `==` against literals answers EXACTLY as measured for Harbour
// casilla strings (oracle hk132: .T./.F./.F./.T. - exact, symmetric,
// no prefix rule). Harbour builds the cell with Array(2) and indexed
// assignment; this PoC keeps string cells in the dedicated DArrS
// surface - same answers on the measured shapes.
function main()
    local a := {}
    AAdd(a, "hola")
    if a[1] == "hola"
        ? 1
    else
        ? 0
    endif
    if a[1] == "hola "
        ? 0
    else
        ? 0
    endif
    if a[1] == "hol"
        ? 0
    else
        ? 0
    endif
    if "hola" == a[1]
        ? 1
    else
        ? 0
    endif
return nil
