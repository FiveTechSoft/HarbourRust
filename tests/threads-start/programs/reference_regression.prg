procedure Main()
local th,r
th:=hb_threadStart(@worker(),4)
hb_threadJoin(th,@r)
? r
return
function worker(n)
return n+1
