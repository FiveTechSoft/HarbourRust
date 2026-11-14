function Main()
local i:=0
local s:=Replicate("ABC",20)
local a:=SubStr(s,2,3)
for i:=1 to 200
 a:=SubStr(Replicate("ABC",20),-5,3)
next
? a,s,SubStr(a,1,0)
return nil
