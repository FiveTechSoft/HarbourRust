function Keep(x)
return x
function Boom()
local a:={1},i:=2
return a[i]
function BoomStr()
Boom()
return Upper("temp")
function W()
local i,x,y,z,c:=0,dummy:=Keep(nil)
for i:=1 to 1000
 x:=Keep(Upper("hello"))
 y:=IIf(.T.,x,"other")
 x:=nil
 z:=Upper("bad-value")
 y:=nil
 x:=Keep(1.25)
 y:=IIf(.F.,"other",x)
 y:=nil
 x:=nil
 y:=IIf(.T.,Upper("temp"),x)
 y:=nil
 TRY
  y:=IIf(Boom()==1,Upper("temp"),x)
 CATCH e
  c++
 END
 TRY
  y:=IIf(.T.,BoomStr(),x)
 CATCH e
  c++
 END
next
return c
function Main()
local b
W()
b:=hb_memcheck()
OutStd(W(),hb_memcheck()-b,Chr(10))
return nil
