#include "hbclass.ch"
CLASS Entry
 DATA stamp
ENDCLASS
FUNCTION CopyCell(x)
RETURN x
FUNCTION Main()
 LOCAL a:={},t:=hb_SToT("20260102"),x,c:="",i
 AAdd(a,t)
 AAdd(a,Replicate("word",7))
 FOR i:=1 TO 113
  FOR EACH x IN a
   ? CopyCell(x)
  NEXT
 NEXT
RETURN NIL
