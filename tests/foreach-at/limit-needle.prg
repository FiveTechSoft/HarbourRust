PROCEDURE Main()
 LOCAL x:=NIL,n:="x"
 FOR EACH x IN hb_ATokens("x",";")
  ? hb_At(n,x)
 NEXT
RETURN
