procedure Main()
local a:=hb_threadStart(@Worker())
local b:=hb_threadStart(@Worker())
hb_threadJoin(a)
hb_threadJoin(b)
? "done"
return
function Worker()
local c:=Replicate("A"+Chr(0)+"B",131073)
local r:=""
local i:=0
for i:=1 to 200
r:=SubStr(c,2,262145)
if Len(r)!=262145.or.Asc(r)!=0.or.Asc(SubStr(r,262145,1))!=66
? "FAIL"
endif
next
return nil
