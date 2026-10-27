function show(x)
return QQOut(x)
function exercise()
local i
local a := AllTrim(" ")
local b := AllTrim(" ")
local c := AllTrim("  abc  ")
for i := 1 to 40
show(a)
show(b)
show(AllTrim(" "))
next
? Len(a), Len(b), c
? show(c) == NIL, c
return
function main()
exercise()
? hb_MemCheck()
return
