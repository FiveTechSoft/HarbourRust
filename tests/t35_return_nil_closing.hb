// a function that early-returns a value cannot close with return nil
function f()
    local x := 1
    if x > 0
        return 5
    endif
return nil
