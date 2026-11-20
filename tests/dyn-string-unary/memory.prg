function Boom()
local a:={1},i:=2
return a[i]
function Normalize(x)
hb_default(@x,"")
return Lower(x)
function Work()
local x,y,z,i
for i:=1 to 100
x:=Upper("old-value")
y:=Lower(x)
x:=Upper("new-value")
z:=Upper("bad-value")
if y!="old-value"
? "bad result"
endif
y:=Upper(hb_defaultValue(nil,"old-value"))
x:=Upper("new-value")
z:=Upper("bad-value")
if y!="OLD-VALUE"
? "bad value snapshot"
endif
y:=AllTrim(hb_defaultValue(nil," x "))
if y!="x"
? "bad trim"
endif
Lower(hb_defaultValue(nil,Upper("discard")))
Upper(hb_defaultValue(nil,Upper("discard")))
AllTrim(hb_defaultValue(nil,Upper("discard")))
y:=Normalize()
TRY
y:=Lower(hb_defaultValue(Upper("pending"),Boom()))
CATCH e
END
x:=nil
next
return nil
function Main()
local i
Work()
? hb_memcheck()
for i:=1 to 100
Work()
next
? hb_memcheck()
return nil
