#include "hbclass.ch"
CLASS Entry
 DATA stamp
ENDCLASS
FUNCTION Observe(x,y)
RETURN ValType(x)+ValType(y)
FUNCTION Fail(x)
 IF ValType(x)=="C"
  Break("stop")
 ENDIF
RETURN NIL
FUNCTION Main()
 LOCAL a:={},t:=hb_SToT("20260102"),x,i,c:="",e,n:=0
 AAdd(a,t)
 AAdd(a,Replicate("word",7))
 FOR i:=1 TO 113
  BEGIN SEQUENCE
   FOR EACH x IN a
    c:=Observe(x,Fail(x))
   NEXT
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,hb_TToS(a[1]),a[2]
RETURN NIL
