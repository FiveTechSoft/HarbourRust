function Round1(nn)
local i,a,b,c,s,e,r,hits
a:=1.5
b:=2
c:=0.25
s:="x"
hits:=0
for i:=1 to nn
 r:=a*b
 r:=a*b*c
 r:=(a*b)*c
 r:=b*c
 r:=NIL
 TRYBLOCK
next
? "hits", hits
return r
function Main()
local baseline, x
x:=Round1(@N@)
baseline:=hb_memcheck()
x:=Round1(@N@)
? "pending", hb_memcheck()-baseline
return nil
