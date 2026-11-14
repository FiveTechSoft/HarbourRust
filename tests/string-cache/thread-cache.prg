procedure Main()
local a:=hb_threadStart(@Worker())
local b:=hb_threadStart(@Worker())
hb_threadJoin(a)
hb_threadJoin(b)
? "done"
return
function Worker()
local i:=0
local a:=Replicate("A",4096)
local b:=AllTrim(a)
for i:=1 to 1000
b:=AllTrim(a)
next
return nil
