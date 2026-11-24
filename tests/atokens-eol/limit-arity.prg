PROCEDURE Main()
 LOCAL a:=hb_ATokens(AllTrim(" a;b "),hb_eol(1))
 ? Len(a)
RETURN
