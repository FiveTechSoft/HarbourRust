#include "hbclass.ch"
CLASS Marker
 DATA n
ENDCLASS
FUNCTION Main()
 LOCAL a:={},t:=hb_SToT("20261123"),b:={}
 AAdd(a,t)
 AAdd(a,"copy"+Str(1,1))
 b:=AClone(a)
 ASize(a,0)
 ? Len(a),Len(b),hb_TToS(b[1]),b[2]
RETURN NIL
