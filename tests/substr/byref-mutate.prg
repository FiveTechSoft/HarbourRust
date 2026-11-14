function Main()
local s:=Replicate("ABC",2)
? SubStr(s,Change(@s),3),s
return nil
function Change(s)
? SubStr(s,1,1)
s:=Replicate("X",10)
return 2
