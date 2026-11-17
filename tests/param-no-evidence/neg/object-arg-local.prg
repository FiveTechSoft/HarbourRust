#include "hbclass.ch"
CLASS K
   DATA n INIT 1
ENDCLASS
FUNCTION Ident(x)
RETURN x
FUNCTION Main()
 LOCAL o
 o := K():New()
  LOCAL z := Ident(o)
RETURN NIL
