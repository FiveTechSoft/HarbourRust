function main()
local a := {}, d := SToD("20261123")
AAdd(a,d)
set date british
set century on
OutStd("[",a[1],"]")
OutErr("[",a[1],"]")
return nil
