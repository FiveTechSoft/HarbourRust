procedure Main()
local th,r
th:=hb_threadStart("worker", side(1),side(2),side(3))
hb_threadJoin(th,@r)
? r
return
function side(n)
? "arg",n
return n
function worker(n)
return n+1
