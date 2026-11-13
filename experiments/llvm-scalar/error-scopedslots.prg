function probe(n)
local i := 0
for i := 1 to 2
if n+0 == 0
local a := {1,2}
? a[i+2]
else
local a := {3,4,5}
? a[i]
endif
next
return 0
function main()
? probe(0)
return
