function work()
  local a := {}
  for i := 1 to 800000
    AAdd(a, i)
  next
  ? len(a), a[1], a[400000], a[800000]
  return 0
function main()
  ? work(), hb_memcheck()
  return nil
