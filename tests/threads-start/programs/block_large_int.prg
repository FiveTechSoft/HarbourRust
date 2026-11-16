procedure Main()
local th,r
th:=hb_threadStart({|n| n},9223372036854775807)
hb_threadJoin(th,@r)
? r
return
