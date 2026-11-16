procedure Main()
local t
t:=hb_threadStart("worker",1.5)
return
function worker(n)
return n+1
