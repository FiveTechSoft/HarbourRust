PROCEDURE Main()
 LOCAL x:=NIL,n:=0,i:=0
 FOR i:=1 TO 137
  FOR EACH x IN hb_ATokens("0x123 0x456"+hb_eol()+"none"+hb_eol()+"",hb_eol())
   n:=hb_At("0x",x,4)
   ? x,n,hb_At("0x",x),hb_At("0x",x,0,3),hb_At("",x),hb_At("n",x,-1)
  NEXT
 NEXT
 ? ValType(x)
RETURN
