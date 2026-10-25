// neg: using a dynamic array after it moved
function consume(a)
  return len(a)
function main()
  local a := {}
  AAdd(a, 1)
  local n := consume(a)
  ? len(a)
  return nil
