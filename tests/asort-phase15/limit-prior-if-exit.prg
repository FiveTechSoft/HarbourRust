FUNCTION Main()
 LOCAL a:={2,1},i,k
 ASort(a)
 FOR i:=1 TO 3
  IF i>0
   EXIT
  ENDIF
  FOR k:=1 TO 7
  NEXT
 NEXT
 ? ValType(k)
RETURN NIL
