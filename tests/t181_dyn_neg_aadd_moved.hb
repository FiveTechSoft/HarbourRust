// neg: AAdd on a moved dynamic array
function consume(a)
  return len(a)
function main()
  local a := {}
  AAdd(a, 1)
  local n := consume(a)
  AAdd(a, 2)
  return nil
