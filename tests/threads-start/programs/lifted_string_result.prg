procedure Main()
local t,r
t:=hb_threadStart({|| "a"})
hb_threadJoin(t,@r)
? r
return
