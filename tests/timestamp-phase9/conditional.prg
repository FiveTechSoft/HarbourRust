#include "hbclass.ch"
CLASS Entry
 DATA stamp
ENDCLASS
FUNCTION Kind(x)
RETURN ValType(x)
FUNCTION Main()
 LOCAL a:={},t:=hb_SToT("20260102"),x,c:="",i
 AAdd(a,t)
 AAdd(a,"text")
 FOR EACH x IN a
  IF Kind(x)=="T"
   c+=Kind(x)
  ELSE
   ? Kind(x)
  ENDIF
 NEXT
 ? c
RETURN NIL
