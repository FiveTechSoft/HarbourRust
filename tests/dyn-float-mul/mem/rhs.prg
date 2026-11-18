STATIC entered := 0
function Fails(v)
 entered := entered + 1
 Break("expected")
return v
function Ok(v)
 entered := entered + 1
return v
function Round1(nn)
local i,a,b,c,e,r,hits
a:=1.5
b:=2
c:=0.25
hits:=0
r:=NIL
for i:=1 to nn
 r:=NIL
TRYBLOCK
next
? "hits", hits
? "a", a
? "r", r
? "entered", entered
return r
function Main()
local baseline, x
x:=Round1(@N@)
baseline:=hb_memcheck()
x:=Round1(@N@)
? "pending", hb_memcheck()-baseline
return nil
