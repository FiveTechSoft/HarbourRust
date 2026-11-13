// an i64 value can be passed twice: integers copy, they do not move
function id(x)
    // `+ 0` only pins the parameter type: the PoC pins from arithmetic or
    // comparison evidence, not from call sites (registered inference limit)
    return x + 0

function main()
    local v := 9
    ? id(v)
    ? id(v)
    ? v
    return nil
