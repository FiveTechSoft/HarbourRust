function Boom()
local a:={1},i:=2
return a[i]
function BadFlag()
Boom()
return .F.
function W()
local h:={=>},k:={=>},i,c:=0,old:=.F.
for i:=1 to 1000
 old:=hb_HCaseMatch(h,.F.)
 h["Host"]:="old-value"
 h["HOST"]:="new-value"
 k:=hb_HClone(h)
 if k["host"]=="new-value" .and. !hb_HCaseMatch(k)
  c++
 endif
 TRY
  old:=hb_HCaseMatch(h,BadFlag())
 CATCH e
  if !hb_HCaseMatch(h)
   c++
  endif
 END
 hb_HClear(h)
 if !hb_HCaseMatch(h)
  c++
 endif
 hb_HClear(k)
 old:=hb_HCaseMatch(h,hb_HCaseMatch(h,.T.))
 hb_HSetCaseMatch(k,.T.)
next
return c
function Main()
local b
W()
b:=hb_memcheck()
OutStd(W(),hb_memcheck()-b,Chr(10))
return nil
