#include "hbclass.ch"
CLASS Entry
 DATA stamp
ENDCLASS
FUNCTION TextOnly(x)
RETURN Upper(x)
FUNCTION Main()
 LOCAL a:={},t:=hb_SToT("20260102"),x,c
 AAdd(a,t)
 AAdd(a,"word")
 FOR EACH x IN a
  c:=TextOnly(x)
 NEXT
RETURN NIL
