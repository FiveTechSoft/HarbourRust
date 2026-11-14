function work()
  local a := {}
  local s := "left" + "right"
  AAdd(a, 41)
  ASize(a, 2000)
  ? s, len(a), a[1], a[2000]
  return 0
function main()
  ? work(), hb_memcheck()
  return nil
