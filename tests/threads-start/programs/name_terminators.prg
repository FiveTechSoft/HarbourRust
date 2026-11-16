procedure Main()
local th,r,name:=Lower("WORKER suffix")
th:=hb_threadStart(name,1)
hb_threadJoin(th,@r)
? r
name:="WoRkEr"+Chr(9)+"suffix"
th:=hb_threadStart(name,2)
hb_threadJoin(th,@r)
? r
name:="WORKER"+Chr(0)+"suffix"
th:=hb_threadStart(name,3)
hb_threadJoin(th,@r)
? r
th:=hb_threadStart("worker suffix",4)
hb_threadJoin(th,@r)
? r
return
function worker(n)
return n+1
