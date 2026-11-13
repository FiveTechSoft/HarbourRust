// HB-EXACT values: a[i] := v on a FLAT dynamic array (v2a checker gap fixed; differential vs Harbour)
function work()
  local a := {}
  AAdd(a, 1)
  AAdd(a, 2)
  a[1] := 42
  return a[1] * 100 + a[2]
function main()
  ? work()
  ? hb_memcheck()
  return nil
