procedure main()
? work()
? hb_memcheck()
return
function floating(n)
return hb_PValue(1)
function work()
local x:=floating(2.500)
local a:={}
local b
AAdd(a,x)
AAdd(a,floating(3.140))
? a[1],a[2]
a[1]:=floating(7.50)
? x,a[1]
ASize(a,1)
? a[1]
b:={1,2,3}
AFill(b,x)
? b[1],b[2],b[3]
ADel(b,1)
AIns(b,1)
ASize(b,1)
? b[1]
return 0
