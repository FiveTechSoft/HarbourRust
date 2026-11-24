#include "hbclass.ch"
CLASS Entry
 DATA stamp
ENDCLASS
FUNCTION Kind(x)
RETURN ValType(x)
FUNCTION Main()
 LOCAL a:={},t:=hb_SToT("20260102"),x,c
 AAdd(a,t)
 FOR EACH x IN a
  c:=Kind(@x)
 NEXT
RETURN NIL
