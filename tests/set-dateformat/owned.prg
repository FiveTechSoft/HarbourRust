FUNCTION Main()
 LOCAL old:=Set(4),i
 FOR i:=1 TO 151
  old:=Set(4,"dd/mm/yyyy")
  old:=Set(4,"mm/dd/yy")
 NEXT
 ? old,Set(4)
 ? DToS(CToD("12/31/1999"))
 Set(4,"yyyy/mm/dd")
 ? DToS(CToD("1999/04/30"))
RETURN NIL
