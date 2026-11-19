#include "hbclass.ch"
CREATE CLASS A
 DATA ClassName INIT "data"
ENDCLASS
CREATE CLASS B
 METHOD ClassName() INLINE "override"
ENDCLASS
FUNCTION Main()
 LOCAL a:=A(), b:=B()
 ? a:ClassName(), b:ClassName()
RETURN NIL
