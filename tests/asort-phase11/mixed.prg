FUNCTION Main()
 LOCAL a:={3,SToD("20260201"),SToD(""),"a",NIL,SToD("20250101")},i
 ASort(a)
 FOR i:=1 TO Len(a)
  IF ValType(a[i])=="D"
   ? DToS(a[i])
  ELSE
   ? ValType(a[i])
  ENDIF
 NEXT
RETURN NIL
