PROCEDURE Main()
 LOCAL x:=NIL,n:=0,i:=0,p:=1
 FOR i:=1 TO 137
  FOR EACH x IN hb_ATokens(";  F;xyz;0123456789ABCDEF", ";")
   n:=hb_HexToNum(SubStr(x,p,18))
   ? n,hb_HexToNum(SubStr(x,999,2)),hb_HexToNum(SubStr(x,1,-1)),hb_HexToNum(SubStr(x,-999,4))
  NEXT
 NEXT
 ? ValType(x)
RETURN
