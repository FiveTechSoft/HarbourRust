// OURS-ONLY: a := a on an array of arrays moves through a temporary; no double free
function work()
  local a := {{1}, {2}}
  a := a
  return a[2][1]
function main()
  ? work()
  ? hb_memcheck()
  return nil
