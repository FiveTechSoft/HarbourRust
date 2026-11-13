// HB-EXACT: the index consumes a String AFTER the value is evaluated (value-first order, probe adv2/as2)
function take(s)
  if s = "zz"
    return 1
  endif
  return 2
function main()
  local a := {10, 20}
  local v := "ab"
  a[take(v)] := 5
  ? a[2]
  return nil
