procedure Main()
local a:=hb_threadStart(@Worker())
local b:=hb_threadStart(@Worker())
hb_threadJoin(a)
hb_threadJoin(b)
? "done"
return
function Worker()
local r:=""
local i:=0
for i:=1 to 200
r:=Replicate(Chr(0),65537)
if Len(r)!=65537 .or. Asc(SubStr(r,32768,1))!=0 .or. Asc(Right(r,1))!=0
? "FAIL ZERO"
endif
r:=Replicate("x",1048576)
if Len(r)!=1048576 .or. Asc(SubStr(r,32768,1))!=120 .or. Asc(Right(r,1))!=120
? "FAIL LARGE"
endif
next
return nil
