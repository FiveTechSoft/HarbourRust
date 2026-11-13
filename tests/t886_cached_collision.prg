function show(x)
return QQOut(x)
function exercise()
local i
local a := AllTrim("12345678")
local b := AllTrim("abcdefghijklmnop")
for i := 1 to 20
show(a)
show(b)
next
? a, b
return
function main()
exercise()
? hb_MemCheck()
return
