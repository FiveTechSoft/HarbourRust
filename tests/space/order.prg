procedure Main()
Work()
return
function Work()
local n:=2
local s:=Space(Change(@n))
? Len(s),n
s:=Space(Count(3))
? "["+s+"]"
? Len(Space(Count(0)))
? Len(Consume(Space(2)))
? Len(Make(4))
? Len(Space(Count(2)+1))
return nil
function Change(n)
? "count",n+0
n:=5
return 3
function Count(n)
? "once",n
return n+0
function Consume(s)
return AllTrim(s)
function Make(n)
return Space(n)
