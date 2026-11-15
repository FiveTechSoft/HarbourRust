procedure Main()
Work()
return
function Work()
local n:=2
local s:=Space(Count(@n))
? Len(s),n
? Len(Space(n/1.0)),n
return nil
function Count(n)
local old:=n/1.0
? "count",n+0
n:=n+2
return old+0.9
