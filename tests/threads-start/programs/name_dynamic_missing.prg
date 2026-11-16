procedure Main()
local th,r,name:="Ident"
th:=hb_threadStart(name)
hb_threadJoin(th,@r)
? ValType(r),r
return
function Ident(s)
return s
