function main()
local i := 0
local x := 1
for i := 1 to 2000000
x += i
if x > 1000003
x -= 1000003
endif
if x > 1000003
x := 0
endif
next
? x
return
