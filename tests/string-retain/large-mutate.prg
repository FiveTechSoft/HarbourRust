procedure Main()
Work()
return
function Work()
local c:=Replicate("A",65537)
local s:=PadR(c,Change(@c))
? Len(s),Asc(s),Asc(SubStr(s,Len(s),1))
c:=Replicate("B",65537)
s:=Replicate(c,Change(@c))
? Len(s),Asc(s),Asc(SubStr(s,Len(s),1))
? Len(c),Asc(c)
return nil
function Change(c)
? Len(SubStr(c,1,65537))
c:=Replicate("X",40)
return 2
