// the step must be a literal in this PoC (an expression is rejected)
function main()
    local s := 2
    for i := 1 to 6 step s
        ? i
    next
return nil
