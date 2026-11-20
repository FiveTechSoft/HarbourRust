function Boom()
local a:={1},i:=2
return a[i]
function W()
local i,x,y,z,c:=0,f:=1.25
for i:=1 to 1000
 x:=Upper("old-value")
 y:=hb_defaultValue(x,"fallback")
 x:=Upper("new-value")
 z:=Upper("bad-value")
 if y=="OLD-VALUE"
  c++
 endif
 y:=nil
 x:=nil
 y:=hb_defaultValue(x,Upper("fallback"))
 if y=="FALLBACK"
  c++
 endif
 y:=nil
 x:=f
 y:=hb_defaultValue(x,7)
 y:=nil
 x:=hb_defaultValue(x,x)
 x:=nil
 y:=hb_defaultValue(hb_defaultValue(nil,Upper("inner")),Upper("outer"))
 y:=nil
 hb_defaultValue(Upper("discard"),Upper("other"))
 TRY
  y:=hb_defaultValue(Upper("outer"),hb_defaultValue(Upper("inner"),Boom()))
 CATCH e
  c++
 END
 x:=nil
 y:=nil
next
return c
function Main()
local b
W()
b:=hb_memcheck()
OutStd(W(),hb_memcheck()-b,Chr(10))
return nil
