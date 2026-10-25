// exit leaves the loop, not the function: the outer array stays usable
function main()
local a := {}
for i := 1 to 10
  AAdd(a, i)
  if i = 5
    exit
  endif
next
? len(a)
? a[5]
return nil
