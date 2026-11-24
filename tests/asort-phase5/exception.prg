FUNCTION Fail()
 Break("stop")
RETURN 1
FUNCTION Main()
 LOCAL a:={1.25,-3,2.5},i,e,n:=0
 FOR i:=1 TO 157
  BEGIN SEQUENCE
   ASort(a,Fail())
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ASort(a)
 ? n,a[1],a[3]
RETURN NIL
