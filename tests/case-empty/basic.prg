procedure Main()
Work()
return
function Work()
local s:=""
local x:=""
? "["+Upper("")+"]"
? "["+Lower("")+"]"
? "["+Upper(Space(0))+"]"
? "["+Lower(Space(0))+"]"
? "["+Upper("aBc 123")+"]"
? "["+Lower("aBc 123")+"]"
s:=Space(0)
x:=Upper(s)
? Len(x)
x:=Lower(s)
? Len(x)
s:="a"+Chr(0)+"Z"+Chr(255)
OutStd(Upper(s))
OutStd(Lower(s))
return nil
