FUNCTION Fail()
 Break("stop")
RETURN 1
FUNCTION SortIt(a)
 ASort(a,Fail())
RETURN NIL
FUNCTION Main()
 LOCAL a:={7,2,9,1},i,e,n:=0
 FOR i:=1 TO 157
  BEGIN SEQUENCE
   SortIt(a)
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,a[1],a[4]
RETURN NIL
