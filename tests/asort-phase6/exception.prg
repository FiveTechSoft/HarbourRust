FUNCTION Fail()
 Break("stop")
RETURN 1
FUNCTION Main()
 LOCAL a:={SToD("20260101"),3,"x",{5},NIL,.F.},i,e,n:=0
 FOR i:=1 TO 157
  BEGIN SEQUENCE
   ASort(a,Fail())
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ASort(a)
 ? n,a[1][1],a[2],a[3],a[4],a[5],ValType(a[6])
RETURN NIL
