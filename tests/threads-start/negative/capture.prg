procedure Main()
local x:=2,t
t:=hb_threadStart({|n| n+x},1)
return
