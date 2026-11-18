#include "hbclass.ch"
CLASS K
   DATA n INIT 1
ENDCLASS
FUNCTION Keep(x)
 IF x == NIL
  x := NIL
 ENDIF
RETURN x
FUNCTION Callee(x, y)
 ? "ENTERED"
RETURN NIL
FUNCTION Main()
 LOCAL o, d
 o := K():New()
 d := Keep(o)
 ? "before"
 Callee(d, 1)
 ? "after"
RETURN NIL
