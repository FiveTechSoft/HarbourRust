// pos: inline `:=` assignments as expressions (original parexpr piece):
// the value is the NEW content; right-associative; nested sequences.
function main()
    local x
    local y
    x := ( y := 10, y )
    ? x
    ? y
    x := ( ( y := ( 1, 2, 3 ) ), y * ( 10, 20, 30 ) )
    ? x
    ? y
    return nil
