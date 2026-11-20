function F(x)
local n:=x
n:=n+0.5
return n
function Crash()
local a:={1},i:=2
return a[i]
function W()
local i,v,n:=0
for i:=1 to 1000
 v:=F(2)
 v:=F(1.25)
 TRY
  OutStd(F(2),Crash())
 CATCH e
  n++
 END
next
return n
function Main()
local b
W()
b:=hb_memcheck()
OutStd(W(),hb_memcheck()-b,Chr(10))
return nil
