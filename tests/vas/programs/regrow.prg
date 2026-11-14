function work()
  local a := {}
  AAdd(a, 1)
  ASize(a, 800)
  a[1] := 11
  a[700] := 77
  ASize(a, 2)
  ASize(a, 800)
  ? a[1], a[2], a[700], len(a)
  ASize(a, 0)
  AAdd(a, 19)
  AAdd(a, a[1])
  ? a[1], a[2]
  return 0
function main()
  ? work(), hb_memcheck()
  return nil
