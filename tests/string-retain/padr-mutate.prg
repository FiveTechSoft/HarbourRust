procedure Main()
Work()
return
function Work()
local c:=Replicate("ABC",2)
? "["+PadR(c,Change(@c))+"]",c
return
function Change(c)
? SubStr(c,1,6)
c:=Replicate("X",40)
return 9
