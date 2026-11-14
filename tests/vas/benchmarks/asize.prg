function work()
  local a := {}
  AAdd(a, 31)
  for i := 1 to 120
    ASize(a, i * 8000)
  next
  ? len(a), a[1], a[960000]
  return 0
function main()
  ? work(), hb_memcheck()
  return nil
