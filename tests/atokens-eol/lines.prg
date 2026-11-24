PROCEDURE Main()
 LOCAL a:=hb_ATokens(AllTrim(" a"+hb_eol()+""+hb_eol()+"b "),hb_eol())
 LOCAL i:=0
 ? Len(a),a[1],a[2],a[3]
 FOR i:=1 TO 513
  a:=hb_ATokens(AllTrim(" x"+hb_eol()+"y "),hb_eol())
 NEXT
 ? Len(a),a[1],a[2]
RETURN
