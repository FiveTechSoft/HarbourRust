PROCEDURE Main()
 LOCAL x:=NIL,s:=";"
 LOCAL a:=hb_ATokens("a",";")
 FOR EACH x IN hb_ATokens("a;b","|")
  a:=hb_ATokens(x,s)
 NEXT
RETURN
