function main()
  local a := {}
  local i
  for i := 1 to 3
    AAdd(a, {|| i})
  next
  ? eval(a[1])
  ? eval(a[3])
  return nil
