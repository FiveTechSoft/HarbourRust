// pos: block IF with a parenthesized comma-sequence condition (one
// top-level comma is NOT inline IIF); NIL-only call as a discarded
// sequence element; single parenthesized inline assignment condition.
function something(x, y, z)
    return nil
function main()
    local x
    local y
    IF ( y := .T. )
        ? "Working"
    ENDIF
    IF ( x := 10, y := ( x == 10 ) )
        ? "Working"
        ? x, y
    ENDIF
    IF ( something(1, 2, 3), .T. )
        ? "Working"
    ENDIF
    return nil
