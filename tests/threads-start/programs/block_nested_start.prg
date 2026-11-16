procedure Main()
local th,r
th:=hb_threadStart({|n| nested(n)+0},100)
hb_threadJoin(th,@r)
? r
return
function nested(n)
local th,r
th:=hb_threadStart({|k| k+1},n+0)
hb_threadJoin(th,@r)
return r
