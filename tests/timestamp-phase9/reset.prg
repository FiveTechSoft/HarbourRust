#include "hbclass.ch"
CLASS Entry
 DATA stamp
ENDCLASS
FUNCTION Main()
 LOCAL a:={},t:=hb_SToT("20260102123456"),i,x
 AAdd(a,t)
 FOR i:=1 TO 211
  AAdd(a,Replicate("ab",i))
  a:={}
  AAdd(a,t)
 NEXT
 ? Len(a),hb_TToS(a[1])
 a:={}
 ? Len(a)
RETURN NIL
