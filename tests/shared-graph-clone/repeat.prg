FUNCTION Work()
 LOCAL a:=AClone({"word",19.25,{"child"}}),b,i
 a[3]:=a
 FOR i:=1 TO 117
  b:=AClone(a)
  b[1]:="changed"
 NEXT
RETURN Len(b)
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL
