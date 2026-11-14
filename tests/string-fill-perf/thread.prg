procedure Main()
local a:=hb_threadStart(@Worker())
local b:=hb_threadStart(@Worker())
hb_threadJoin(a)
hb_threadJoin(b)
? "done"
return
function Worker()
local c:="A"+Chr(0)+"B"
local r:=""
local i:=0
for i:=1 to 1000
r:=PadR(c,257)
if Len(r)!=257 .or. Asc(SubStr(r,2,1))!=0 .or. Asc(SubStr(r,257,1))!=32
? "FAIL PADR"
endif
r:=Replicate(c,85)
if Len(r)!=255 .or. Asc(SubStr(r,254,1))!=0 .or. Asc(SubStr(r,255,1))!=66
? "FAIL REPLICATE"
endif
r:=Replicate("x",4096)
if Len(r)!=4096 .or. Asc(SubStr(r,4096,1))!=120
? "FAIL FILL"
endif
next
return nil
