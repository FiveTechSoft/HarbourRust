FUNCTION Main()
 LOCAL i,k,a:={},b:={2,1}
 ASort(b)
 FOR i:=1 TO 3
  FOR k:=1 TO 7
   AAdd(a,"x")
  NEXT
 NEXT
 ? i,k,Len(a)
RETURN NIL
