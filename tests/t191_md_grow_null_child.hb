// Repaired NIL-vs-null semantics (oracles n1/n3/n6/n7): a grown casilla
// is Harbour's NIL: it prints NIL, len/AAdd/ASize on it are clean
// errors (Harbour dialogs hang headless), and assigning an array into
// the casilla works. Balance 0 across the function boundary.
function work()
  local a := {{1}, {2}}
  ASize(a, 4)
  a[3] := {9, 9}
  return len(a) * 100 + a[3][1] * 10 + len(a[3])
function main()
  ? work()
  ? hb_memcheck()
  return nil
