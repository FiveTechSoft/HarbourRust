// neg: moved on the exit path, used after the loop
function consume(a)
  return len(a)
function main()
  local a := {}
  AAdd(a, 1)
  for i := 1 to 2
    if i = 2
      local n := consume(a)
      exit
    endif
  next
  ? len(a)
  return nil
