#include "hbclass.ch"
CLASS K
   DATA n INIT 1
ENDCLASS
FUNCTION Keep(x)
 IF x == NIL
  x := NIL
 ENDIF
RETURN x
FUNCTION Pair(x, y)
 ? y:n
RETURN x
FUNCTION Main()
 LOCAL o, d, p
 o := K():New()
 p := K():New()
 d := Keep(o)
 Pair(d, p)
RETURN NIL
