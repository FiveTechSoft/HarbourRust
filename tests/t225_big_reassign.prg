// >1 page (cap 256 -> 4104 B): the old block is freed on reassignment.
// The work happens in a callee so every free lands before memcheck reads.
function work()
  local a := {}
  for i := 1 to 200
    AAdd(a, i)
  next
  local b := {}
  AAdd(b, 7)
  a := b
  return a[1]
function main()
  ? work()
  ? hb_memcheck()
  return nil
