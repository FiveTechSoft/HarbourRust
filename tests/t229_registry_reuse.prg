// 20000 alloc/free pairs through the registry: freed entries are reused
// (swap-with-last), so the count never accumulates past a few live blocks.
function work()
  for i := 1 to 20000
    local b := {}
    AAdd(b, i)
  next
  return 1
function main()
  ? work()
  ? hb_memcheck()
  return nil
