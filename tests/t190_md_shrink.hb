// OURS-ONLY: ASize shrink drops the removed children (Harbour m8 shows the observable reduction only); our recursive free proven by balance 0
function work()
  local a := {{1}, {2}, {3}}
  ASize(a, 1)
  return len(a) * 100 + a[1][1]
function main()
  ? work()
  ? hb_memcheck()
  return nil
