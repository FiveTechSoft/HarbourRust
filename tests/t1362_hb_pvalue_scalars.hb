// hb_PValue(n): the n-th declared parameter as a Dyn casilla (integer,
// string, logical); an out-of-range index is NIL (multiarg family).
function p(k, s, l)
    ? hb_PValue(1), hb_PValue(2), hb_PValue(3), hb_PValue(4)
    return nil
function main()
    p(5, "abc", .t.)
    return nil
