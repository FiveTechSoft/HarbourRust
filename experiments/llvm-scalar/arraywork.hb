function arraywalk(n)
local a := {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
local i := 0
local j := 1
local s := 0
for i := 1 to n
a[j] := a[j] + i
j := j + 1
if j > 16
j := 1
endif
next
for i := 1 to len(a)
s := s + a[i]
next
return s
function main()
? arraywalk(1000)
return
