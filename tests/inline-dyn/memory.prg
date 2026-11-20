function Keep(x)
return x
function Boom()
local a:={1},i:=2
return a[i]
function W()
local i,x,y,c:=0,dummy:=Keep(nil)
for i:=1 to 1000
 x:=Upper("hello")
 (x:=x)
 y:=(x:=x)
 y:=nil
 x:=1.25
 y:=(x:=x)
 y:=nil
 x:=nil
 TRY
  OutStd((x:=Keep(Upper("temp"))),Boom())
 CATCH e
  c++
 END
 x:=nil
 TRY
  y:=(x:=Keep(Boom()))
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
