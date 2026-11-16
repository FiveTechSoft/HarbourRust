procedure Main()
local th,r,name:="one"
th:=hb_threadStart(name,20)
hb_threadJoin(th,@r)
? r
name:="two"
th:=hb_threadStart(name,20,3)
hb_threadJoin(th,@r)
? r
return
function one(n)
return n+1
function two(n,k)
return n+k
