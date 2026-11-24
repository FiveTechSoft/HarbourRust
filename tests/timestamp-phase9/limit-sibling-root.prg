#include "hbclass.ch"
CLASS Entry
 DATA stamp
ENDCLASS
FUNCTION Observe(x,y)
RETURN ValType(x)+ValType(y)
FUNCTION Main()
 LOCAL a:={},t:=hb_SToT("20260102"),x,c
 AAdd(a,t)
 FOR EACH x IN a
  c:=Observe(x,a:={})
 NEXT
RETURN NIL
