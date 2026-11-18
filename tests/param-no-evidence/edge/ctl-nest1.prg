#include "hbclass.ch"
CLASS K
ENDCLASS
FUNCTION G(s)
RETURN s + "!"
FUNCTION F(a, x)
RETURN NIL
FUNCTION Main()
 LOCAL s := "a" + "b", d := NIL
 F("abc", d)
 ? "ok"
RETURN NIL
