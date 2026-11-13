// neg: inline `:=` targets an existing local only (Harbour would create
// a private; that scope widening is not this increment).
function main()
    ? ( z := 1, z )
    return nil
