function main()
local i := 0
local t := .T.
for i := 1 to 2000
If(t, AllTrim(" a "), AllTrim(" b "))
next
? hb_memcheck()
return
