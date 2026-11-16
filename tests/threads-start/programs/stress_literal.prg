procedure Main()
local th,r,i,total:=0,b:={|n| n+1},name:="worker"
for i:=1 to 1000
th:=hb_threadStart({|n| n+1},i)
hb_threadJoin(th,@r)
total:=total+r
th:=hb_threadStart(name,i)
hb_threadJoin(th,@r)
total:=total+r
next
? total
return
function worker(n)
return n+1
