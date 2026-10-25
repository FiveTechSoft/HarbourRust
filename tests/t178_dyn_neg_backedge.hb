// neg: moved inside a for body and not reassigned before next
function consume(a)
  return len(a)
function main()
  local a := {}
  AAdd(a, 1)
  for i := 1 to 2
    local n := consume(a)
  next
  return nil
