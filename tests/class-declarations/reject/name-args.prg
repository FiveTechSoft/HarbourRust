#include "hbclass.ch"
CREATE CLASS A
ENDCLASS
FUNCTION Main()
 LOCAL a:=A()
 ? a:ClassName(1)
RETURN NIL
