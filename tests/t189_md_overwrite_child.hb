// OURS-ONLY: overwriting a[i] frees the old child once, after the RHS exists; balance 0
function work()
  local a := {{1, 2}, {3, 4}}
  local c := {}
  AAdd(c, 9)
  a[1] := c
  local d := {}
  AAdd(d, 7)
  a[1] := d
  return a[1][1] * 100 + len(a[1])
function main()
  ? work()
  ? hb_memcheck()
  return nil
