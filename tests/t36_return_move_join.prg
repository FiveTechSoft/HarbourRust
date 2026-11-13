// a string moved into an early return stays moved on that path: using it
// after the if joins both paths and must fail
function f()
    local a := "hola"
    if 1 > 0
        return a
    endif
    ? a
    return 0
function main()
    ? f()
return nil
