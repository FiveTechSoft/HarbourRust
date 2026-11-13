// >2 pages (cap 512 -> 8200 B): `local` re-declare inside a loop frees the
// previous iteration's block; the last one dies at the callee epilogue.
function work()
  local i := 0
  while i < 3
    local b := {}
    for j := 1 to 300
      AAdd(b, j)
    next
    i := i + 1
  enddo
  return i
function main()
  ? work()
  ? hb_memcheck()
  return nil
