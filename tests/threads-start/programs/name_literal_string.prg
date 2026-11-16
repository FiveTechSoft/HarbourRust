procedure Main()
local th,r
th:=hb_threadStart("Ident", "hello")
hb_threadJoin(th,@r)
? ValType(r),r
return
function Ident(s)
return s
