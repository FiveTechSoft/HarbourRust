// neg: a local cannot reuse a parameter name (no shadowing in this PoC)
function f(a)
    local a := 1
    return a

function main()
    ? f(5)
    return nil
