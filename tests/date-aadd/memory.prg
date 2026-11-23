function main()
local i, a := {}, b := {}
for i := 1 to 300
AAdd(a,SToD("20261123"))
AAdd(a,SToD(""))
AAdd(b,a[1])
next
ASize(a,2)
ASize(b,1)
? ValType(a[1]),a[1],ValType(a[2]),a[2],ValType(b[1]),b[1]
return nil
