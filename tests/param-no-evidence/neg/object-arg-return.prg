#include "hbclass.ch"
CLASS K
   DATA n INIT 1
   DATA ref INIT NIL
ENDCLASS
FUNCTION Ident(x)
RETURN x
FUNCTION Mk()
RETURN K():New()
FUNCTION Main()
 LOCAL o, z
 o := K():New()
  Ident(Mk())
RETURN NIL
