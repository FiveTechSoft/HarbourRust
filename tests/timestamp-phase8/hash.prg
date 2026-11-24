#include "hbclass.ch"
CLASS Entry
 DATA stamp
 METHOD Put(x)
ENDCLASS
METHOD Put(x) CLASS Entry
 ::stamp:=x
RETURN Self
FUNCTION Main()
 LOCAL o:=Entry():New(),t:=hb_SToT("20261123101530987"),h:={=>},i
 h["stamp"]:=t
 o:Put(h["stamp"])
 ? ValType(h["stamp"]),hb_TToS(h["stamp"]),ValType(o:stamp),hb_TToS(o:stamp)
RETURN NIL
