procedure Main()
local th,r,name:="worker"
th:=hb_threadStart(name)
hb_threadJoin(th,@r)
? r
return
function worker()
return 9
