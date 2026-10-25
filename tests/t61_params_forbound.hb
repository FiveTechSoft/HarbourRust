// a parameter can drive a for loop bound
function sumto(n)
    local s := 0
    for i := 1 to n
        s := s + i
    next
    return s

function main()
    ? sumto(100)
    return nil
