FUNCTION Work()
 LOCAL a:={{NIL,.T.,"old"}},i
 FOR i:=1 TO 117
  a[1,1]:=Replicate("word",31)
  a[1,3]:=i
 NEXT
RETURN a[1,3]
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL
