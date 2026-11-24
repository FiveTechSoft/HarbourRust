FUNCTION Main()
 LOCAL mask:="yyyy-mm-dd",old:=Set(4),i
 FOR i:=1 TO 151
  old:=Set(4,mask)
  mask:="yY-mM-dD"
  old:=Set(4,mask)
  mask:="yyyy-mm-dd"
 NEXT
 ? old,Set(4),0d19990430,__SetCentury()
 ? DToS(CToD("99-04-30")),DToS(CToD("1999/04/30"))
RETURN NIL
