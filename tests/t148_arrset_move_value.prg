// HB-EXACT: the value consumes a String in indexed assignment
function take(s)
  if s = "zzz"
    return 1
  endif
  return 0
function main()
  local a := {10, 20}
  local v := "zz"
  a[1] := take(v)
  ? a[1]
  return nil
