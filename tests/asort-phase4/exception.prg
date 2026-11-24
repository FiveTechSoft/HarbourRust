FUNCTION Fail()
 Break("stop")
RETURN "unused"
FUNCTION Main()
 LOCAL a:={7,2,9,1},i,e,n:=0
 FOR i:=1 TO 157
  BEGIN SEQUENCE
   ASort(a,NIL,NIL,Fail())
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,a[1],a[4],Len(ASort(a))
RETURN NIL
