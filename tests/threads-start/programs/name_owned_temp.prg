procedure Main()
local th,r
th:=hb_threadStart(Lower("WORKER"), 4)
hb_threadJoin(th,@r)
? r
return
function worker(n)
return n+3
