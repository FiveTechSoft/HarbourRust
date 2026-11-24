#include "hbclass.ch"
CLASS Entry
 DATA stamp
 METHOD Put(x)
ENDCLASS
METHOD Put(x) CLASS Entry
 ::stamp:=x
RETURN Self
FUNCTION UpperText(s)
RETURN Upper(s)
FUNCTION Main()
 LOCAL t:=hb_SToT("20261123")
 ? UpperText("x")
RETURN NIL
