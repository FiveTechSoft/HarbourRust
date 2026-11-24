FUNCTION Work()
 LOCAL a:={{NIL}},b,i
 a[1,1]:=1
 FOR i:=1 TO 117
  b:=AClone({"word",{19.25,SToD("20040229")}})
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
