// a := a moves through a temporary: no double free, value survives
function main()
  local a := {}
  AAdd(a, 5)
  a := a
  ? a[1]
  return nil
