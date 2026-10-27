function main()
local i := 0
local s := 0
for i := 1 to 1000000
s += If(i % 2 == 0, 3, 1)
next
? s, i
return
