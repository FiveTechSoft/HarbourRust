procedure Main()
local th, r
th := hb_threadStart({|n| QOut("first",n), n+2}, 5)
? hb_threadJoin(th,@r),r
return
