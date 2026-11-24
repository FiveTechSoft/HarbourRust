PROCEDURE Main()
 LOCAL x:=NIL,n:=1
 FOR EACH x IN hb_ATokens("x",";")
  ? hb_At("x",x,n)
 NEXT
RETURN
