#include "hbclass.ch"
CLASS Marker
 DATA n
ENDCLASS
FUNCTION Main()
 LOCAL a:={},t:=hb_SToT("20261123101530987"),s:="ow"+"ned"
 AAdd(a,t)
 AAdd(a,"literal")
 AAdd(a,s)
 AAdd(a,"temp"+Str(1,1))
 ? Len(a),hb_TToS(a[1]),a[2],a[3],a[4],s
RETURN NIL
