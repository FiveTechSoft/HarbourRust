PROCEDURE Main()
 LOCAL a:=NIL,x:="a;b"
 a:=hb_ATokens(x,";")
 Touch(@a)
RETURN
PROCEDURE Touch(a)
 ? ValType(a)
RETURN
