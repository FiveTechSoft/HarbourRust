// regression: a void function (`return nil`) WITH parameters must compile.
// Previously no signature entry was recorded for void functions and codegen
// panicked with expect("checked"). The function is intentionally never
// called (a void call cannot appear in an expression in this PoC).
function show(a, b)
  ? a + b
  return nil
function main()
  ? 42
  return nil
