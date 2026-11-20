function Boom()
local a:={1},i:=2
return a[i]
function Work()
local x,z,i
for i:=1 to 5
x:=Upper("abcdefgh")
z:=Left(x,(hb_default(@x,7)==nil,hb_default(@x,Upper("zzzzzzzz"))==nil,3))
if z!="ABC"
? "bad left snapshot"
endif
x:=Upper("abcdefgh")
z:=Right(x,(hb_default(@x,7)==nil,hb_default(@x,Upper("zzzzzzzz"))==nil,3))
if z!="FGH"
? "bad right snapshot"
endif
x:=Upper("abcdefgh")
TRY
z:=Left(x,Boom())
CATCH e
if x!="ABCDEFGH"
? "bad left catch source"
endif
END
TRY
z:=Right(hb_defaultValue(nil,Upper("abcdefgh")),Boom())
CATCH e
if x!="ABCDEFGH"
? "bad right catch source"
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
