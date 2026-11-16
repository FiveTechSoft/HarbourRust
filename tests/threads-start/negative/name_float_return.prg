procedure Main()
local t
t:=hb_threadStart("worker")
return
function worker()
return 1.5
