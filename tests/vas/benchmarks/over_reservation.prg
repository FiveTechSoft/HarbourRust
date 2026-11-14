function work()
  local a := {}
  AAdd(a, 17)
  ASize(a, 1100000)
  ? len(a), a[1], a[1100000]
  ASize(a, 3)
  ASize(a, 1100000)
  ? len(a), a[1], a[1100000]
  return 0
function main()
  ? work(), hb_memcheck()
  return nil
