procedure Main()
Work()
return
function Work()
local a:=Replicate("A",4096)
local b:=Replicate("B",8192)
local c:=Replicate("C",12288)
local d:=Replicate("D",65536)
local i:=0
local total:=0
for i:=1 to 100
 a:=AllTrim(Replicate("A",4096))
 b:=AllTrim(Replicate("B",8192))
 c:=AllTrim(Replicate("C",12288))
 d:=AllTrim(Replicate("D",65536))
 total:=total+Len(a)+Len(b)+Len(c)+Len(d)
 total:=total+Asc(a)+Asc(SubStr(a,Len(a),1))
 total:=total+Asc(b)+Asc(SubStr(b,Len(b),1))
 total:=total+Asc(c)+Asc(SubStr(c,Len(c),1))
 total:=total+Asc(d)+Asc(SubStr(d,Len(d),1))
next
? total
return nil
