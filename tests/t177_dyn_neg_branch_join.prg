// neg: moved in one if-branch, used after the join (moved flags union)
function consume(a)
  return len(a)
function main()
  local a := {}
  AAdd(a, 1)
  if 1 = 1
    local n := consume(a)
  endif
  ? len(a)
  return nil
