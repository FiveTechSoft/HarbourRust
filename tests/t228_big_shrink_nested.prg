// shrink-nested: ASize(e, 1) frees two >2-page children via the deep path.
function work()
  local e := {{}, {}, {}}
  for j := 1 to 300
    AAdd(e[1], j)
    AAdd(e[2], j)
    AAdd(e[3], j)
  next
  ASize(e, 1)
  return len(e)
function main()
  ? work()
  ? hb_memcheck()
  return nil
