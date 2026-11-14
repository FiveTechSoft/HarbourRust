function work()
  local a := {}
  for i := 1 to 20
    if i = 7
      loop
    endif
    AAdd(a, i)
    if i = 15
      exit
    endif
  next
  ? len(a), a[1], a[14]
  return 0
function main()
  ? work(), hb_memcheck()
  return nil
