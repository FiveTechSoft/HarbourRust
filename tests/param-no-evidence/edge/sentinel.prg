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
FUNCTION Callee2(x, y)
 ? "ENTERED"
RETURN NIL
FUNCTION Callee3(x, y)
 ? "ENTERED"
RETURN NIL
FUNCTION Main()
 LOCAL o, d, e
 o := K():New()
 d := Keep(o)
 TRY
  Callee(d, 1)
 CATCH e
  ? "caught1"
 END
 TRY
  Callee2(1, d)
 CATCH e
  ? "caught2"
 END
 TRY
  Callee3(d)
 CATCH e
  ? "caught3"
 END
 ? "end"
RETURN NIL
