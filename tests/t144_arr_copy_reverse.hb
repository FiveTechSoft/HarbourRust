// MODEL: array assignment COPIES (Rust [i64; N] is Copy); mutating the source afterwards leaves the copy intact. Harbour shares a reference: there b[1] would print 5
function main()
  local a := {10, 20, 30}
  local b := a
  a[1] := 5
  ? b[1]
  ? a[1]
  return nil
