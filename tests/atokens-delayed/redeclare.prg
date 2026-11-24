PROCEDURE Main()
 LOCAL x:="a;b",i:=0
 FOR i:=1 TO 3
  LOCAL a:=NIL
  a:=hb_ATokens(x,";")
  ? Len(a)
 NEXT
RETURN
