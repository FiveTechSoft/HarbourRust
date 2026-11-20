function Boom()
local a:={1},i:=2
return a[i]
function W()
local i,v,n:=0
for i:=1 to 1000
 v:=Min(2,1.25)
 v:=Max(2,1.25)
 TRY
  v:=Min(1.25,Boom())
 CATCH e
  n++
 END
 TRY
  v:=Max(Boom(),1.25)
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
