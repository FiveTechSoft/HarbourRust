// comparing strings borrows both: they stay usable (and movable) after
function main()
    local a := "hola"
    local b := "hola"
    if a = b
        ? "eq"
    endif
    ? a
    ? b
    local c := a
    ? c
return nil
