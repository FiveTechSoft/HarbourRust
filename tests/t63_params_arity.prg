// neg: too many arguments (too FEW is Harbour's NIL fill - t1361 family)
function add(a, b)
    return a + b

function main()
    ? add(1, 2, 3)
    return nil
