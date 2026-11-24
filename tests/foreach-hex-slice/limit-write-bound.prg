PROCEDURE Main()
 LOCAL x:=NIL,n:=0,p:=1
 FOR EACH x IN hb_ATokens("FF",";")
  n:=hb_HexToNum(SubStr(x,(p:=1),2))
 NEXT
RETURN
