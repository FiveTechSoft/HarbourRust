// negative: using the result of a void function (`return nil`) in an
// expression is a clean type error, not a panic or "unknown function".
function show(a, b)
  ? a + b
  return nil
function main()
  ? show(1, 2)
  return nil
