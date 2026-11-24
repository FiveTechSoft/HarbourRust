FUNCTION Empty()
RETURN {}
FUNCTION Main()
 LOCAL a:={},i,k,b:={2,1}
 ASort(b)
 FOR i:=1 TO 3
  a:=Empty()
  FOR k:=1 TO 7
   AAdd(a,"x")
  NEXT
 NEXT
 ? i,k,Len(a)
RETURN NIL
