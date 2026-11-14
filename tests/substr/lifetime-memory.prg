procedure Main()
Work()
? hb_memcheck()
return
function Work()
local s:=Replicate("ABC",3)
local a:=SubStr(s,2,4)
local b:=SubStr(SubStr(s,2,6),-3)
s:=Replicate("X",20)
? a,b,s
? SubStr("AB"+"CD",2,2)+SubStr(Replicate("EF",2),-2)
? SubStr(a,2),a,b
return nil
