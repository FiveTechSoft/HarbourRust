#include "hbclass.ch"
CLASS Marker
 DATA n
ENDCLASS
FUNCTION FailText()
 Break("stop")
RETURN "bad"
FUNCTION Work()
 LOCAL a:={},t:=hb_SToT("20261123"),i,e,n:=0
 FOR i:=1 TO 101
  a:={}
  AAdd(a,t)
  AAdd(a,"kept"+Str(i,3))
  BEGIN SEQUENCE
   AAdd(a,"prefix"+FailText())
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,Len(a),a[2]
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL
