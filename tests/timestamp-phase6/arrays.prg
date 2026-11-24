FUNCTION Compare(a,b)
RETURN a<=b
FUNCTION Main()
 LOCAL a:={},d:=SToD("20261123"),t:=hb_SToT("20261123")
 AAdd(a,d)
 AAdd(a,SToD("20261124"))
 ? Compare(a[1],a[2]),Compare(d,a[2]),ValType(a[1])
RETURN NIL
