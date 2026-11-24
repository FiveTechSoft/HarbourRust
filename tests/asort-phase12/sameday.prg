FUNCTION Main()
 LOCAL a:={},i
 AAdd(a,hb_SToT("20260102101530"))
 AAdd(a,SToD("20260102"))
 AAdd(a,hb_SToT("20260102091530"))
 AAdd(a,SToD("20260102"))
 ASort(a)
 FOR i:=1 TO Len(a)
  ? ValType(a[i]),hb_TToS(a[i])
 NEXT
RETURN NIL
