// Harbour fills omitted trailing parameters with NIL (multiarg family):
// b arrives as a NIL casilla and prints NIL; a provided call is exact.
function show(a, b)
    ? a, b
    return nil
function main()
    show(7)
    show(8, 9)
    return nil
