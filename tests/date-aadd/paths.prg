function main()
local a := {}, b := {}, d := SToD("20261123"), e := SToD("")
AAdd(a,d)
AAdd(a,e)
AAdd(a,1)
AAdd(a,.T.)
AAdd(a,NIL)
AAdd(b,a[1])
? ValType(a[1]), a[1], ValType(a[2]), a[2]
? ValType(b[1]), b[1]
set date british
set century on
? a[1], b[1], a[2]
set date german
set century off
? a[1]
? ValType(a[3]), ValType(a[4]), ValType(a[5])
return nil
