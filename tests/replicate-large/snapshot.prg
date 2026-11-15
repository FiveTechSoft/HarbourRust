procedure Main()
Work()
return
function Work()
local c:=Chr(0)
local s:=Replicate(c,Change(@c))
? Len(s),Asc(s),Asc(Right(s,1)),c
c:="x"+""
s:=Replicate(c,Change(@c))
? Len(s),Asc(s),Asc(Right(s,1)),c
return nil
function Change(c)
? Len(SubStr(c,1,1))
c:=Replicate("M",40)
return 65537
