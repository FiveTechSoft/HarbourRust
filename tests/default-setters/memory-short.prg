function Boom()
local a:={1},i:=2
return a[i]
function Work()
local x,d,z,i
for i:=1 to 10
x:=nil
d:=Upper("default")
__defaultNIL(@x,d)
d:=Upper("new")
z:=Upper("bad")
if x!="DEFAULT"
? "bad selected snapshot"
endif
x:=2
__defaultNIL(@x,Upper("not selected"))
if x!=2
? "bad nil only"
endif
hb_default(@x,Upper("text"))
if x!="TEXT"
? "bad replace kind"
endif
hb_default(@x,7.5)
hb_default(@x,8)
if x!=7.5
? "bad numeric category"
endif
__defaultNIL(@x,x)
hb_default(@x,x)
x:=Upper("kept")
TRY
hb_default(@x,hb_defaultValue(Upper("pending"),Boom()))
CATCH e
if x!="KEPT"
? "bad exception changed slot"
endif
END
x:=nil
next
return nil
function Main()
local i
Work()
? hb_memcheck()
for i:=1 to 10
Work()
next
? hb_memcheck()
return nil
