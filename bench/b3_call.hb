function f()
return 42

function main()
local s := 0
for i := 1 to 20000000
  s := s + f()
next
? s
return nil
