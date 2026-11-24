PROCEDURE Main()
 LOCAL a:=NIL
 FOR EACH a IN hb_aTokens(ad_missing_read("not-read.txt"),hb_eol())
  ? a
 NEXT
RETURN
