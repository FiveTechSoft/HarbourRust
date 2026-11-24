FUNCTION Main()
 LOCAL mask:="dd/mm/yyyy",old:=Set(4),i
 FOR i:=1 TO 151
  old:=Set(4,mask)
  mask:="mM/dD/yY"
  old:=Set(4,mask)
  mask:="dd/mm/yyyy"
 NEXT
 ? old,Set(4),DToC(SToD("19990430")),__SetCentury()
RETURN NIL
