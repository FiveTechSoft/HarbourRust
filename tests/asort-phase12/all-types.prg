FUNCTION Main()
 LOCAL a:={},i
 AAdd(a,3)
 AAdd(a,hb_SToT("20260102101530"))
 AAdd(a,"z")
 AAdd(a,NIL)
 AAdd(a,.T.)
 AAdd(a,SToD("20260102"))
 AAdd(a,.F.)
 AAdd(a,1.25)
 AAdd(a,hb_SToT(""))
 AAdd(a,SToD(""))
 ASort(a)
 FOR i:=1 TO Len(a)
  ? ValType(a[i]),a[i]
 NEXT
RETURN NIL
