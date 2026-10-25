// the loop variable may not reuse a name already in scope (this PoC does
// not shadow)
function main()
    local i := 9
    for i := 1 to 2
        ? i
    next
return nil
