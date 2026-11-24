#include "hbclass.ch"
CLASS Entry
 DATA stamp
ENDCLASS
FUNCTION Kind(x)
RETURN ValType(x)
FUNCTION Main()
 LOCAL a:={},t:=hb_SToT("20260102123456"),x,c:="",i
 AAdd(a,t)
 AAdd(a,Replicate("word",7))
 AAdd(a,SToD("20251231"))
 AAdd(a,NIL)
 FOR i:=1 TO 113
  c:=""
  FOR EACH x IN a
   c+=Kind(x)+" "
  NEXT
 NEXT
 ? c,hb_TToS(a[1]),a[2],a[3]
RETURN NIL
