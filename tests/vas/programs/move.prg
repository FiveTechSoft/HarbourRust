function grow(a)
  ASize(a, 800)
  a[800] := 33
  return a
function work()
  local a := {}
  AAdd(a, 7)
  a := grow(a)
  a := a
  ? len(a), a[1], a[800]
  return 0
function main()
  ? work(), hb_memcheck()
  return nil
