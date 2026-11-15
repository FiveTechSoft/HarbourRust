procedure Main()
Work()
return
function Work()
local n:=0.0
local s:=""
local k:=0
local j:=0
local bad:=0
? Len(Space(-3.9)),Len(Space(-0.9)),Len(Space(-0.0)),Len(Space(0.9)),Len(Space(1.9)),Len(Space(2.9))
for j:=-7 to 17
n:=j/2.0
s:=Space(n)
bad:=0
for k:=1 to Len(s)
if Asc(SubStr(s,k,1))!=32
bad:=bad+1
endif
next
? Len(s),bad
next
? Len(Take(2.9)),Len(TakeFloat(2.9))
s:=Space(65535.9)
? Len(s),Asc(s),Asc(Right(s,1))
s:=Space(65536.9)
? Len(s),Asc(s),Asc(Right(s,1))
s:=Space(65537.9)
? Len(s),Asc(s),Asc(Right(s,1))
return nil
function Take(n)
return Space(n)
function TakeFloat(n)
return Space(n*1.0)
