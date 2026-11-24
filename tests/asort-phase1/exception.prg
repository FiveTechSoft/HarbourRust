FUNCTION Fail()
 Break("stop")
RETURN 1
FUNCTION Main()
 LOCAL a:={4,3,2,1},i,e,n:=0
 FOR i:=1 TO 137
  BEGIN SEQUENCE
   ASort(a,Fail())
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ASort(a)
 ? n,a[1],a[4]
RETURN NIL
