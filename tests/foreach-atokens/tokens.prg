PROCEDURE Main()
 LOCAL x:=NIL
 LOCAL a:=hb_ATokens("seed",";")
 LOCAL i:=0
 FOR i:=1 TO 137
  FOR EACH x IN hb_ATokens("a;b"+hb_eol()+""+hb_eol()+"x;;y",hb_eol())
   a:=hb_ATokens(x,";")
   ? Len(a),a[1],a[Len(a)]
  NEXT
 NEXT
 ? ValType(x)
RETURN
