procedure Main()
local th, r, b := {|a,b| a*10+b}
th := hb_threadStart(b, 4,2,999)
? hb_threadJoin(th,@r),r
return
