PROCEDURE Main()
 LOCAL x:=NIL,n:=0
 FOR EACH x IN hb_ATokens("FF",";")
  n:=hb_HexToNum(SubStr(x,Side(),2))
 NEXT
RETURN
FUNCTION Side()
RETURN 1
