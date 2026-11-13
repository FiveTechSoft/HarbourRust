// moved in the body but reassigned before enddo: allowed, and the
// reassigned value is live after the loop
function main()
    local a := "x"
    local i := 0
    while i < 2
        local b := a
        ? b
        a := "y"
        i := i + 1
    enddo
    ? a
return nil
