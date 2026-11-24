FUNCTION Work()
 LOCAL a:={{NIL}},b:=Array(0),i
 a[1,1]:=1
 FOR i:=1 TO 117
  b:=Array(23)
  b[1]:=Replicate("word",31)
 NEXT
RETURN Len(b)
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL
