// OURS-ONLY: assigning a pinned array pins the empty {}; move semantics; balance 0
function work()
  local a := {}
  local b := {}
  AAdd(b, 5)
  a := b
  return len(a) * 100 + a[1]
function main()
  ? work()
  ? hb_memcheck()
  return nil
