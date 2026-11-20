function Boom()
local a:={1},i:=2
return a[i]
function Work()
local x,z,i
for i:=1 to 5
x:=Upper("abcdefgh")
z:=SubStr(x,(hb_default(@x,7)==nil,hb_default(@x,Upper("zzzzzzzz"))==nil,2),3)
if z!="BCD"
? "bad position snapshot"
endif
x:=Upper("abcdefgh")
z:=SubStr(x,2,(hb_default(@x,7)==nil,hb_default(@x,Upper("zzzzzzzz"))==nil,3))
if z!="BCD"
? "bad length snapshot"
endif
x:=Upper("abcdefgh")
TRY
z:=SubStr(x,Boom())
CATCH e
if x!="ABCDEFGH"
? "bad position source"
endif
END
TRY
z:=SubStr(hb_defaultValue(nil,Upper("abcdefgh")),Boom(),3)
CATCH e
if x!="ABCDEFGH"
? "bad position3 source"
endif
END
TRY
z:=SubStr(hb_defaultValue(nil,Upper("abcdefgh")),2,Boom())
CATCH e
if x!="ABCDEFGH"
? "bad count source"
endif
END
x:=nil
next
return nil
function Main()
local i
Work()
? hb_memcheck()
for i:=1 to 5
Work()
next
? hb_memcheck()
return nil
