// sibling branches may reuse a local name (branch scope); a string moved
// in both branches is moved at the join (using it after would be an error)
function main()
    local a := "hola"
    if 1 < 2
        local b := a
        ? b
    else
        local b := a
        ? b
    endif
    ? "fin"
return nil
