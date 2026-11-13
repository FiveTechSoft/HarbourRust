// >2 pages child (cap 512): overwriting d[1] frees the old child exactly.
function work()
  local d := {{}, {}}
  for j := 1 to 300
    AAdd(d[1], j)
  next
  local c := {}
  AAdd(c, 7)
  d[1] := c
  return d[1][1]
function main()
  ? work()
  ? hb_memcheck()
  return nil
