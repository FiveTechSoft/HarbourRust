FUNCTION Work()
 LOCAL a:=AClone({"one","two",19.25}),i
 FOR i:=1 TO 117
  ADel(a,1)
  a[1]:="new"
  a[3]:=19.25
 NEXT
RETURN Len(a)
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL
