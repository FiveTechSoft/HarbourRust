FUNCTION Work()
 LOCAL a:={{NIL}},b:={},i,n:=0
 a[1,1]:=1
 FOR i:=1 TO 117
  AAdd(b,Replicate("word",31))
  n+=Len(ATail(b))
  ASize(b,0)
  AAdd(b,{"one","two"})
  n+=Len(ATail(b))
  ASize(b,0)
 NEXT
RETURN n
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL
