procedure Main()
local th,r,name:="MuL"
th:=hb_threadStart(name,7,6)
hb_threadJoin(th,@r)
? r
return
function mul(a,b)
return a*b
