// alloc/free balance across function boundaries: each work() frees its array at its own epilogue
function work()
  local a := {}
  AAdd(a, 1)
  AAdd(a, 2)
  AAdd(a, 3)
  AAdd(a, 4)
  AAdd(a, 5)
  return len(a)
function main()
  local x := work()
  x := work()
  ? hb_memcheck()
  return nil
