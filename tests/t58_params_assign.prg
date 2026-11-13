// a parameter is an owned local: it can be reassigned inside the function
function twice(x)
    x := x * 2
    return x

function main()
    ? twice(21)
    return nil
