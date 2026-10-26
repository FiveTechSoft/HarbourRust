function mut(x)
  ? len(x)
  ? x[1]
  x[1] := "tres"
  AAdd(x, "cuatro")
return 0
function main()
  local a := {}
  AAdd(a, "uno")
  AAdd(a, "dos")
  ? mut(a)
  ? a[1]
  ? len(a)
return NIL
