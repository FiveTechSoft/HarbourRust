FUNCTION Work()
 LOCAL s:=OS(), d, i, n:=0
 FOR i:=1 TO 1000
  s:=OS()
  d:=OS()
  n:=n+Len(s)+Len(d)
 NEXT
 ? n, s, d
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL
