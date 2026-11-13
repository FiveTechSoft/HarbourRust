// a variable moved before `loop` must be reassigned first (next iteration)
function main()
    local a := "x"
    local i := 0
    while i < 3
        local b := a
        ? b
        i := i + 1
        loop
    enddo
return nil
