PROCEDURE Main()
 LOCAL a:=NIL,x:="a;b",i:=0
 LOCAL b:={|| ValType(a)}
 a:=hb_ATokens(x,";")
RETURN
