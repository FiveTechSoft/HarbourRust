#include "hbclass.ch"
CLASS Entry
 DATA stamp
 METHOD Put(x)
ENDCLASS
METHOD Put(x) CLASS Entry
 ::stamp:=x
RETURN Self
FUNCTION Main()
 LOCAL o:=Entry():New(),t:=hb_SToT("20261123101530987"),i
 FOR i:=1 TO 101
  o:Put(t)
 NEXT
 ? ValType(o:stamp),hb_TToS(o:stamp),hb_TToC(o:stamp,"YYYY-MM-DD","HH:MM:SS.fff")
RETURN NIL
