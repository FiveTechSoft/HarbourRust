FUNCTION Work()
 LOCAL a:={1,"text"},b
 a[1]:=a
 b:=a
 a[2]:=Replicate("word",31)
 b[1]:=NIL
RETURN Len(a[2])
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 317
  n+=Work()
 NEXT
 ? n
RETURN NIL
