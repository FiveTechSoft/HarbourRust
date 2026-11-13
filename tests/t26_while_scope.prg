// loop-body locals are scoped to the body
function main()
    local i := 0
    while i < 1
        local z := 9
        ? z
        i := i + 1
    enddo
    ? z
return nil
