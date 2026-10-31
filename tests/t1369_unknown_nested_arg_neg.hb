// neg: an unknown function nested in a user-call argument is a clean
// named rejection, never a compiler panic (preexisting hole in the
// placeholder-parameter skip; verifier results-63f29286).
function take(s)
    ? s
    return nil
function main()
    take(Replicate("ab", 3))
    return nil
