procedure Main()
local t1,t2,r
 t1:=hb_threadStart({|n| n+1},10)
 t2:=hb_threadStart({|n| n+2},10)
 hb_threadJoin(t1,@r)
 ? r
 hb_threadJoin(t2,@r)
 ? r
return
