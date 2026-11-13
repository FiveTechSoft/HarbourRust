// neg: moved inside a while body on a path that reaches loop
function consume(a)
  return len(a)
function main()
  local a := {}
  AAdd(a, 1)
  local i := 0
  while i < 2
    i := i + 1
    local n := consume(a)
    loop
  enddo
  return nil
