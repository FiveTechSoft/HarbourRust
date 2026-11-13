// neg: a generic Dyn call (mixed scalar/nil returns type Dyn) stays a
// named limit as a discarded sequence element; NIL-only calls are the
// admitted shape.
function d(x)
    if x > 0
        return 5
    endif
    return nil
function main()
    ? ( d(1), 1 )
    return nil
