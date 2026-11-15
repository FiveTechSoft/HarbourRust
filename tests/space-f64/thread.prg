procedure Main()
local a:=hb_threadStart(@Worker())
local b:=hb_threadStart(@Worker())
hb_threadJoin(a)
hb_threadJoin(b)
? "done"
return
function Worker()
local i:=0
local s:=""
for i:=1 to 1000
s:=Space(4096.9)
if Len(s)!=4096 .or. Asc(s)!=32 .or. Asc(SubStr(s,4096,1))!=32
? "FAIL"
endif
next
return nil
