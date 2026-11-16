procedure Main()
local th,r,name:="worker",a:={1,2,3}
? alen(a)
th:=hb_threadStart(name,4)
hb_threadJoin(th,@r)
? r
return
function worker(n)
return n+1
function alen(a)
return Len(a)
