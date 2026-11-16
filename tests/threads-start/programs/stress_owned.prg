procedure Main()
local t,r,i,name:=Lower("WORKER")
for i:=1 to 200
t:=hb_threadStart(name,Lower("VALUE"))
hb_threadJoin(t,@r)
if r != "value"
? "bad",i
endif
next
? r,i
return
function worker(s)
return s
