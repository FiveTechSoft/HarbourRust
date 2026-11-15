procedure Main()
local a:=hb_threadStart(@Worker())
local b:=hb_threadStart(@Worker())
hb_threadJoin(a)
hb_threadJoin(b)
? "done"
return
function Worker()
local i:=0
local c:=Replicate("A"+Chr(0)+"B",100)
local r:=""
for i:=1 to 1000
r:=StrTran(c,Chr(0),"XY")
if Len(r)!=400 .or. Asc(SubStr(r,2,1))!=88 .or. Asc(SubStr(r,400,1))!=66
? "FAIL"
endif
next
return nil
