procedure Main()
Work()
return
function Work()
local c:=Replicate("ab",32769)
local q:=Replicate("ab",1)
local r:=Replicate("Z",1)
local n:=2
local out:=""
out:=StrTran(c,q,r,Start(@c,@q,@r),Count(@n))
? Len(out),Asc(out),Asc(SubStr(out,Len(out),1)),Len(c),Len(q),Len(r),n
c:=Replicate("a",65537)
q:=Replicate("a",1)
r:=Replicate("Z",1)
out:=StrTran(c,q,r,Start(@c,@q,@r),0)
? Len(out),Len(c),Len(q),Len(r)
n:=2
? StrTran("aaaa","a","X",n,Count(@n)),n
out:=StrTran(Replicate("a",4),AllTrim("a"),AllTrim("X"),2,1)
? out
? Apply("aaaa","a","X",2,1)
return nil
function Apply(c,q,r,n,k)
return StrTran(c,q,r,n,k)
function Start(c,q,r)
? "start",Len(SubStr(c,1,65537)),SubStr(q,1,40),SubStr(r,1,40)
c:=Replicate("B",40)
q:=Replicate("C",40)
r:=Replicate("D",40)
return 2
function Count(n)
? "count",n+0
n:=3
return 1
