// pos: NIL-only detection only trusts return EXPRESSIONS. A conditional
// bare return plus the closing `return nil` stays NIL-only (discarded
// in a sequence); a recursive NIL-only function is NIL-only too (the
// recursive call is a statement, never a returned value). A function
// returning any expression is NOT NIL-only (named limit, t1378).
function cond_ret(x)
    if x > 0
        return
    endif
    return nil
function rec_nil(n)
    if n > 1
        rec_nil(n - 1)
    endif
    return nil
function main()
    ? ( cond_ret(1), "ok" )
    ? ( cond_ret(0), "ok" )
    ? ( rec_nil(3), "ok" )
    return nil
