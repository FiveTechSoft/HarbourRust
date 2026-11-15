procedure Main()
Work()
return
function Work()
local s:=""
local i:=0
for i:=1 to 10000
s:=Upper("")
s:=Lower(s)
s:=Upper(Space(0))
s:=Lower("")
next
? Len(s)
return nil
