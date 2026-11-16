procedure Main()
local t,a:={1,2}
t:=hb_threadStart("worker",a)
return
function worker(n)
return n+1
