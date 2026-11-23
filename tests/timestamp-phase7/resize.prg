#include "hbclass.ch"
CLASS Marker
 DATA n
ENDCLASS
FUNCTION Main()
 LOCAL a:={},t:=hb_SToT("20261123"),i
 AAdd(a,t)
 FOR i:=1 TO 101
  AAdd(a,"text"+Str(i,3))
 NEXT
 ASize(a,2)
 ? Len(a),a[2],hb_TToS(a[1])
 ASize(a,5)
 ? Len(a),ValType(a[3])
 ASize(a,0)
 ? Len(a)
RETURN NIL
