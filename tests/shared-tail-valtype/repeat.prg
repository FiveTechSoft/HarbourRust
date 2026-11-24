FUNCTION Work()
 LOCAL a:={{NIL}},b:={},i,c
 a[1,1]:=1
 FOR i:=1 TO 117
  AAdd(b,Replicate("word",31))
  c:=ValType(ATail(b))
  c:=ValType(ATail(b))
  ASize(b,0)
  AAdd(b,19.25)
  c:=ValType(ATail(b))
  ASize(b,0)
 NEXT
RETURN c
FUNCTION Main()
 LOCAL i,c
 FOR i:=1 TO 37
  c:=Work()
 NEXT
 ? c
RETURN NIL
