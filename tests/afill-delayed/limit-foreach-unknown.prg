PROCEDURE Main()
 LOCAL a:=NIL
 FOR EACH a IN hb_aTokens(hb_memoRead("not-read.txt"),hb_eol())
  ? a
 NEXT
RETURN
