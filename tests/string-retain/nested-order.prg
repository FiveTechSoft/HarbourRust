procedure Main()
Work()
return
function Work()
local c:=Replicate("abc",2)
? PadR(Source(@c),Count(@c))
? c
c:=Replicate("def",2)
? Replicate(Source(@c),Count(@c))
? c
return nil
function Source(c)
? "source",SubStr(c,1,6)
return AllTrim(c)
function Count(c)
? "count",SubStr(c,1,6)
c:=Replicate("Q",40)
return 3
