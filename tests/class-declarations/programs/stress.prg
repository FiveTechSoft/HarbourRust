#include "hbclass.ch"
CREATE CLASS Root
 METHOD Name() INLINE ::ClassName()
ENDCLASS
CREATE CLASS Child FROM Root
ENDCLASS
FUNCTION Work()
 LOCAL o:=Child()
 LOCAL i, n:=0, s:=""
 FOR i:=1 TO 1000
  s:=o:Name()
  n:=n+Len(s)+Len(Child():ClassName())
 NEXT
 ? n, s
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL
