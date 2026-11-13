// when every path through the body returns, no reassignment is needed
function f()
    local a := "x"
    for i := 1 to 3
        if i > 0
            return a
        else
            return "z"
        endif
    next
    return "z"
function main()
    ? f()
return nil
