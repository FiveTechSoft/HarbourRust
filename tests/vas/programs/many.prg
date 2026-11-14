function work()
  local a := {}
  AAdd(a, 1)
  local b := {}
  AAdd(b, 1)
  local c := {}
  AAdd(c, 1)
  local d := {}
  AAdd(d, 1)
  ASize(a, 2000)
  ASize(b, 3000)
  ASize(c, 4000)
  ASize(d, 5000)
  a[1] := 10
  b[1] := 20
  c[1] := 30
  d[1] := 40
  ? len(a), len(b), len(c), len(d), a[1], d[1]
  a := b
  ? len(a), a[1]
  return 0
function main()
  ? work(), hb_memcheck()
  return nil
