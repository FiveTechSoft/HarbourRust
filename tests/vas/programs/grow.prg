function work()
  local a := {}
  for i := 1 to 4000
    AAdd(a, i)
  next
  ? len(a), a[1], a[257], a[4000]
  return 0
function main()
  ? work()
  ? hb_memcheck()
  return nil
