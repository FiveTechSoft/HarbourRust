PROCEDURE Main()
 LOCAL x:=NIL
 LOCAL a:=hb_ATokens("a",";")
 x:="a;b"
 a:=hb_ATokens(x,";")
 ? Len(a)
RETURN
