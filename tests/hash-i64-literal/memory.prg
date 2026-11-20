function Boom()
local a:={1},i:=2
return a[i]
function Keep(x)
return x
function W()
local h:={=>},k:={=>},i,x,dummy:=Keep(nil),z,c:=0
for i:=1 to 1000
 h[10]:="old-value"
 x:=Keep(Upper("hello"))
 h[20]:=x
 x:=nil
 z:=Upper("bad-value")
 h["000000000000000A"]:=3
 h[9007199254740993]:=4
 h[9007199254740992]:=5
 h[-1]:=6
 h[0]:=7
 h[30]:=8
 h[40]:=9
 if h[10]=="old-value" .and. h[20]=="HELLO" .and. h["000000000000000A"]==3 .and. h[9007199254740993]==4 .and. h[9007199254740992]==5
  c++
 endif
 k:=hb_HClone(h)
 hb_HDelAt(h,1)
 hb_HCopy(k,h)
 hb_HMerge(h,k)
 TRY
  h[10]:=Boom()
 CATCH e
  if h[10]=="old-value"
   c++
  endif
 END
 hb_HFill(h,1)
 hb_HClear(h)
 hb_HClear(k)
next
return c
function Main()
local b
W()
b:=hb_memcheck()
OutStd(W(),hb_memcheck()-b,Chr(10))
return nil
