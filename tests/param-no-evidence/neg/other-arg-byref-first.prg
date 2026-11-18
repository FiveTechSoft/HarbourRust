#include "hbclass.ch"
CLASS K
   DATA n INIT 1
ENDCLASS
FUNCTION Keep(x)
 IF x == NIL
  x := NIL
 ENDIF
RETURN x
FUNCTION Two(y, x)
 y := y + "z"
RETURN x
FUNCTION Main()
 LOCAL o := K():New()
 LOCAL d := Keep(o)
 LOCAL s := "ab" + "cd"
 LOCAL e
 TRY
  Two(@s, d)
 CATCH e
  ? "caught"
 END
 ? s
RETURN NIL
