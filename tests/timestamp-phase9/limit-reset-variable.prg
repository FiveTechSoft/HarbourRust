#include "hbclass.ch"
CLASS Entry
 DATA stamp
ENDCLASS
FUNCTION Main()
 LOCAL a:={},b:={},t:=hb_SToT("20260102")
 AAdd(a,t)
 a:=b
 ? Len(a)
RETURN NIL
