procedure Main()
Work()
return
function Work()
local i:=0
set talk ON
set echo ON
? ProcName(),ProcLine()
for i:=1 to 2
set talk OFF
set echo OFF
? i,ProcLine()
next
return
