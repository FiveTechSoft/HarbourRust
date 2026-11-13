// >2 pages (cap 1024 -> 8+1024*16 = 16392 B): freed at the function epilogue.
// The allocation registry verifies the exact unmap length (munmap fix).
function work()
  local a := {}
  for i := 1 to 1000
    AAdd(a, i)
  next
  return len(a)
function main()
  ? work()
  ? hb_memcheck()
  return nil
