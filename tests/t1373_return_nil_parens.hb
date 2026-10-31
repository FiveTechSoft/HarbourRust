// pos: `Return( NIL )` is the same value-free NIL return as bare
// `return nil` (parexpr.prg's own form), in main and in a function.
function something()
    Return( NIL )
function main()
    ? something()
    Return( NIL )
