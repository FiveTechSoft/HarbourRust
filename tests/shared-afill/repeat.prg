FUNCTION Work()
 LOCAL a:=AClone({"one","two",19.25}),i
 FOR i:=1 TO 117
  AFill(a,Replicate("word",31))
  a[1]:=19.25
  AFill(a,a[1])
  AFill(a,.T.,0,2)
 NEXT
RETURN Len(a)
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL
