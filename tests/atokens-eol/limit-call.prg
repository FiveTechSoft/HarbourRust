FUNCTION te_sep()
RETURN ";"
PROCEDURE Main()
 LOCAL a:=hb_ATokens(AllTrim(" a;b "),te_sep())
 ? Len(a)
RETURN
