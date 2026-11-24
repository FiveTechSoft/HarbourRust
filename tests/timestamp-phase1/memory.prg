function f(t)
return hb_TToS(t)
function main()
local i,t := hb_SToT(""),a := {},x
for i := 1 to 300
t := hb_SToT("20261123"+"101530999")
x := f(t)
AAdd(a,t)
next
? ValType(a[1]), hb_TToS(a[1]),x
ASize(a,0)
? hb_TToS(t)
return nil
