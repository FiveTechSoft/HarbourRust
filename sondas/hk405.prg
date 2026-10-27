function show(x)
if .F.
QQOut(x)
endif
return NIL
function main()
local i
local n := 0
for i := 1 to 10000
if show("xxxxxxxx") == NIL
n++
endif
next
? n
return
