FUNCTION Put(a,x)
 a[1]:=x
RETURN NIL
FUNCTION Main()
 LOCAL a:={1,"old"},i
 FOR i:=1 TO 317
  Put(a,Replicate("word",31))
 NEXT
 ? a[1],a[2]
RETURN NIL
