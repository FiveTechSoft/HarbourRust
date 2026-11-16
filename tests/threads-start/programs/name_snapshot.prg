procedure Main()
local th,r,name:=Lower("ONE")
th:=hb_threadStart(name,mutate(@name))
hb_threadJoin(th,@r)
? r, name
return
function mutate(s)
s:="two"
return 3
function one(n)
return n+1
function two(n)
return n+2
