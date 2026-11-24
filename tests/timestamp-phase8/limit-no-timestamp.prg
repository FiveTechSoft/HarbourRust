#include "hbclass.ch"
CLASS Entry
 DATA stamp
 METHOD Put(x)
ENDCLASS
METHOD Put(x) CLASS Entry
 ::stamp:=x
RETURN Self
FUNCTION Main()
 LOCAL o:=Entry():New()
 o:Put(1)
 ? ValType(o:stamp)
RETURN NIL
