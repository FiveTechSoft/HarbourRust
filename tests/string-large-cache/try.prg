procedure Main()
Work()
return
function Work()
local e
local a:={1}
local c:=""
local k:=0
for k:=1 to 12
try
c:=Replicate("A",65536+k)
c:=SubStr(c,1,Len(c))
? Len(c),a[Idx()]
catch e
? "caught"
end
next
? Len(c),Asc(c)
return nil
function Idx()
return 2
