// neg: ASize on a moved dynamic array
function consume(a)
  return len(a)
function main()
  local a := {}
  AAdd(a, 1)
  local n := consume(a)
  ASize(a, 3)
  return nil
