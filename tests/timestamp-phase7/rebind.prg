#include "hbclass.ch"
CLASS Marker
 DATA n
ENDCLASS
FUNCTION Work()
 LOCAL a:={},t:=hb_SToT("20261123"),i
 FOR i:=1 TO 101
  a:={}
  AAdd(a,t)
  AAdd(a,"text"+Str(i,3))
 NEXT
 ? Len(a),a[2]
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL
