procedure Main()
local th,r
th:=hb_threadStart("Observe")
hb_threadJoin(th,@r)
? r
return
function Observe(s)
? ValType(s)
return 7
