function main()
local i := 0
local x := 1
for i := 1 to 2000000
x := hb_bitAnd(hb_bitXor(x*3+i,i-7),65535)
next
? x
return
