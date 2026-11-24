PROCEDURE Main()
 LOCAL x:=NIL,n:=0,i:=0,p:=3
 FOR i:=1 TO 149
  FOR EACH x IN hb_ATokens("0x0041;0xFFFF;0x00ab;0x0020", ";")
   n:=hb_HexToNum(SubStr(x,3,4))
   ? n,hb_HexToNum(SubStr(x,p+1-1,4)),hb_HexToNum(SubStr(x,-2)),hb_HexToNum(SubStr(x,0,0))
  NEXT
 NEXT
 ? n,ValType(x)
RETURN
