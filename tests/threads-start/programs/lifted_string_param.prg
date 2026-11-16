procedure Main()
local t,r
t:=hb_threadStart({|n| n}, "a")
hb_threadJoin(t,@r)
? r
return
