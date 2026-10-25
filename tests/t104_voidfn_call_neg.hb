// a function closing with `return nil` RETURNS NIL (probe n1c): its result
// is usable in an expression. `? show(1, 2)` first prints the sum from
// inside the call, then the returned NIL.
function show(a, b)
  ? a + b
  return nil
function main()
  ? show(1, 2)
  return nil
