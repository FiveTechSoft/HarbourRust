procedure Main()
local th,r
th:=hb_threadStart("sUm",10,20,30)
hb_threadJoin(th,@r)
? r
return
function sum(a,b,c)
return a+b+c
