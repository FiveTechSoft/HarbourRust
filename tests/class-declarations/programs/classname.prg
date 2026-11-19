#include "hbclass.ch"
CREATE CLASS Root
 METHOD Name() INLINE ::ClassName()
ENDCLASS
CREATE CLASS Child FROM Root
ENDCLASS
FUNCTION Main()
 LOCAL a := Root()
 LOCAL b := Child()
 ? a:ClassName(), b:ClassName(), b:Name()
 ? Len(b:ClassName()), b:ClassName()+"!"
RETURN NIL
