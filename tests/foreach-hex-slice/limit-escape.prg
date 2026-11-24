PROCEDURE Main()
 LOCAL x:=NIL,n:=0
 FOR EACH x IN hb_ATokens("FF",";")
  n:=Borrow(x)
 NEXT
RETURN
FUNCTION Borrow(s)
RETURN Len(s)
