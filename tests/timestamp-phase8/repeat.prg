#include "hbclass.ch"
CLASS Entry
 DATA stamp
 METHOD Put(x)
ENDCLASS
METHOD Put(x) CLASS Entry
 ::stamp:=x
RETURN Self
FUNCTION Work()
 LOCAL o:=Entry():New(),t:=hb_SToT("20261123")
 o:Put(t)
RETURN hb_TToS(o:stamp)
FUNCTION Main()
 LOCAL i,s:=""
 FOR i:=1 TO 517
  s:=Work()
 NEXT
 ? s
RETURN NIL
