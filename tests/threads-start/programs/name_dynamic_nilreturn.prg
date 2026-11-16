procedure Main()
local th,r,name:="worker"
th:=hb_threadStart(name,4)
hb_threadJoin(th,@r)
? ValType(r)
return
procedure worker(n)
? "worker",n
return
