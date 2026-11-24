FUNCTION Work()
 LOCAL a:={{NIL}},b:={},i,c
 a[1,1]:=1
 FOR i:=1 TO 117
  AAdd(b,Replicate("word",31))
  c:=ATail(b)
  c:=ATail(b)
  ASize(b,0)
  AAdd(b,19.25)
  c:=ATail(b)
  ASize(b,0)
 NEXT
RETURN 4
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL
