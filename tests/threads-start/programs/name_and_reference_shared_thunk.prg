procedure Main()
local t,r,name:="worker"
t:=hb_threadStart(@worker(),1)
hb_threadJoin(t,@r)
? r
t:=hb_threadStart(name,2,3)
hb_threadJoin(t,@r)
? r
t:=hb_threadStart("worker",4)
hb_threadJoin(t,@r)
? r
return
function worker(n)
return n+1
