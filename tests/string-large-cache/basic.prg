procedure Main()
Work()
return
function Work()
local n:=0
local k:=0
local j:=0
local bad:=0
local want:=0
local c:=""
local r:=""
for n:=65535 to 65537
c:=Replicate("A"+Chr(0)+Chr(255),n)
for k:=1 to 3
r:=SubStr(c,1,n)
bad:=0
for j:=1 to Len(r)
want:=iif(j%3==1,65,iif(j%3==2,0,255))
if Asc(SubStr(r,j,1))!=want
bad:=bad+1
endif
next
? Len(r),bad
next
next
for n:=1 to 4
c:=Space(262144+n)
r:=StrTran(c," ","XYZ",2,3)
? Len(r),Asc(r),Asc(SubStr(r,Len(r),1))
r:=PadR("Z",1048575+n)
? Len(r),Asc(r),Asc(SubStr(r,Len(r),1))
next
return nil
