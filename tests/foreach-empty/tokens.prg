PROCEDURE Main()
 LOCAL x:=NIL
 FOR EACH x IN hb_ATokens(AllTrim(" a"+hb_eol()+" "+hb_eol()+""+hb_eol()+"b "),hb_eol())
  ? x,Empty(x)
 NEXT
RETURN
