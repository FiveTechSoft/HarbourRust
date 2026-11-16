procedure Main()
local t,r,name:="worker"
t:=hb_threadStart(name)
hb_threadJoin(t,@r)
? r
return
function worker()
return Lower("VALUE")
