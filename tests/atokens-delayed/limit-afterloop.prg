PROCEDURE Main()
 LOCAL a:=NIL,x:="a;b",i:=0
 FOR i:=1 TO 0
  a:=hb_ATokens(x,";")
 NEXT
 ? Len(a)
RETURN
