function main()
local i := 0
local x := 1
for i := 2000000 to 1 step -1
x := hb_bitAnd(x*3+i,65535)
next
? x
return
