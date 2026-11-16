procedure Main()
local th,r
th:=hb_threadStart(getname(), side(1),side(2))
hb_threadJoin(th,@r)
? r
return
function getname()
? "name"
return "worker"
function side(n)
? "arg",n
return n
function worker(a,b)
return a*10+b
