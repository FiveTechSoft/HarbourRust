// Own MIT: mask input survives the discarded owned previous-mask result.
FUNCTION Work()
 LOCAL mask:="dd/mm/yyyy",old:=Set(4),i
 FOR i:=1 TO 151
  SET DATE FORMAT TO mask
  old:=Set(4)
  mask:="MM-DD-YY"
  SET DATE FORMAT mask
  mask:="dd/mm/yyyy"
 NEXT
 ? mask,old,Set(4),DToC(SToD("20010203"))
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL
