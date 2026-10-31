// pos: a builtin call nested in a user-function argument evaluates and
// passes its value (the recovered positive shape of the t1369 guard).
function take(s)
    ? s
    return nil
function main()
    take(Replicate("ab", 3))
    return nil
