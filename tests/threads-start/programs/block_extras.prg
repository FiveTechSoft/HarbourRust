procedure Main()
local th,r
th:=hb_threadStart({|a| a+1}, side(10),side(20),side(30))
hb_threadJoin(th,@r)
? r
return
function side(n)
? "side",n
return n
