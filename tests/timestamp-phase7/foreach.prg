#include "hbclass.ch"
CLASS Marker
 DATA n
ENDCLASS
FUNCTION Main()
 LOCAL a:={},t:=hb_SToT("20261123"),x,c:=""
 AAdd(a,t)
 AAdd(a,"text"+Str(1,1))
 AAdd(a,.T.)
 AAdd(a,SToD("20260102"))
 FOR EACH x IN a
  ? x
 NEXT
RETURN NIL
