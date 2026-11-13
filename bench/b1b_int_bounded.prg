function main()
local n := 0
for i := 1 to 100000000
  n := n + i
  if n > 1000000
    n := n - 1000003
    if n > 1000000
      n := 0
    endif
  endif
next
? n
return nil
