// passing a dynamic array MOVES it; the callee returns it back (Harbour aliases instead - probe e9 - but this program prints the same values)
function grow(a)
  AAdd(a, 99)
  return a
function main()
  local a := {}
  AAdd(a, 1)
  a := grow(a)
  ? len(a)
  ? a[2]
  return nil
