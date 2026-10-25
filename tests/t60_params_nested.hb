// calls as arguments of other calls
function add(a, b)
    return a + b

function main()
    ? add(add(1, 2), add(3, 4))
    return nil
