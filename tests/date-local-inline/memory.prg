function Boom()
local a:={1},i:=2
return a[i]
function BoomDate()
Boom()
return StoD("20260203")
function W()
local d,i,c:=0
 d:=StoD("20260101")
for i:=1 to 1000
 d:=(d:=StoD("20260203"))
 d:=(d:=d+1)
 TRY
  d:=(d:=BoomDate())
 CATCH e
  if d==StoD("20260204")
   c++
  endif
 END
next
return c
function Main()
local b
W()
b:=hb_memcheck()
OutStd(W(),hb_memcheck()-b,Chr(10))
return nil
