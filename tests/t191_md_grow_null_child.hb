// OURS-ONLY: ASize grow zero-fills (null children read len 0, AAdd on them works); balance 0. Harbour grows NIL (probe e1) - documented i64-model difference
function work()
  local a := {{1}, {2}}
  ASize(a, 4)
  AAdd(a[4], 5)
  return len(a) * 100 + len(a[3]) * 10 + a[4][1]
function main()
  ? work()
  ? hb_memcheck()
  return nil
