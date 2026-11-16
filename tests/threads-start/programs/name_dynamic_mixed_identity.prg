procedure Main()
local t,r,name:="ident"
t:=hb_threadStart(name,"hello")
hb_threadJoin(t,@r)
? ValType(r),r
t:=hb_threadStart(name,100)
hb_threadJoin(t,@r)
? ValType(r),r
return
function ident(x)
return x
