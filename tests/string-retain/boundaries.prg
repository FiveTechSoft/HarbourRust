procedure Main()
Work()
return
function Work()
local c:=Replicate("A"+Chr(0)+"B",1)
? Len(PadR(c,Count(0))),Len(PadR(c,Count(-2)))
? Len(PadR(c,Count(2))),Asc(SubStr(PadR(c,Count(2)),2,1))
? Len(PadR(c,Count(5))),Asc(SubStr(PadR(c,Count(5)),5,1))
? Len(Replicate(c,Count(0))),Len(Replicate(c,Count(-2)))
? Len(Replicate(c,Count(2))),Asc(SubStr(Replicate(c,Count(2)),5,1))
? Len(PadR("",Count(3))),Len(Replicate("",Count(3)))
? Len(PadR(AllTrim(" xyz "),Count(5)))
? Len(Replicate(AllTrim(" xyz "),Count(2)))
return nil
function Count(n)
return n+0
