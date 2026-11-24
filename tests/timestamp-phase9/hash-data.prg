#include "hbclass.ch"
CLASS Entry
 DATA stamp
 METHOD Put(x)
ENDCLASS
METHOD Put(x) CLASS Entry
 ::stamp:=x
RETURN Self
FUNCTION Kind(x)
RETURN ValType(x)
FUNCTION Main()
 LOCAL o:=Entry():New(),a:={},h:={=>},t:=hb_SToT("20260102123456789"),x,c:=""
 h["t"]:=t
 o:Put(h["t"])
 AAdd(a,o:stamp)
 AAdd(a,SToD("20251231"))
 FOR EACH x IN a
  c+=Kind(x)
 NEXT
 ? c,hb_TToS(o:stamp),hb_TToS(h["t"])
RETURN NIL
