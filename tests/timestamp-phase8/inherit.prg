#include "hbclass.ch"
CLASS Entry
 DATA stamp
 METHOD Put(x)
ENDCLASS
METHOD Put(x) CLASS Entry
 ::stamp:=x
RETURN Self
CLASS Child FROM Entry
ENDCLASS
FUNCTION Main()
 LOCAL o:=Child():New(),t:=hb_SToT("20261123")
 o:Put(t)
 ? ValType(o:stamp),hb_TToS(o:stamp),o:ClassName()
RETURN NIL
