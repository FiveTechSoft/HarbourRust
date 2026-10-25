// a variable moved in the body must be reassigned before `next`
function main()
    local a := "x"
    for i := 1 to 3
        local b := a
        ? b
    next
return nil
