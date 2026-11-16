procedure Main()
local th,r,name:="my__worker"
th:=hb_threadStart(name,4)
hb_threadJoin(th,@r)
? r
return
function my__worker(n)
return n+1
