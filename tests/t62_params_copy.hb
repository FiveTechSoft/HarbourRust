// an i64 value can be passed twice: integers copy, they do not move
function id(x)
    return x

function main()
    local v := 9
    ? id(v)
    ? id(v)
    ? v
    return nil
