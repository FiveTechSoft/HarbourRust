procedure Main()
Work()
return
function Work()
local c:="a"+Chr(0)+Chr(255)+"a"+Chr(0)+Chr(255)+"a"
local r:=""
local n:=0
for n:=-1 to 4
r:=StrTran(c,Chr(0),Chr(255)+Chr(0),n,1)
OutStd(r,Chr(10))
r:=StrTran(c,Chr(0)+Chr(255),"",n,-2)
OutStd(r,Chr(10))
next
? Len(StrTran(Replicate("a",65537),"aa","XYZ",2,32767))
? Len(StrTran(Replicate("a",65536),"aa","",1,32768))
? Len(StrTran(Replicate("a",65535),"a","XY",65535,1))
? StrTran("aaaaa","aa","X",(-9223372036854775807-1),1)
? StrTran("aaaaa","aa","X",1,(-9223372036854775807-1))
return nil
