FUNCTION SortIt(a)
 ASort(a)
RETURN Len(a)
FUNCTION Main()
 LOCAL a:={7,2,9,1},b,i,n:=0
 b:=a
 FOR i:=1 TO 157
  n+=SortIt(a)
  b[1]:=7
 NEXT
 ? n,a[1],b[4]
RETURN NIL
