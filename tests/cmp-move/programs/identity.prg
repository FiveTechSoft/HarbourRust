#include "hbclass.ch"
CREATE CLASS T
 DATA value INIT 1
ENDCLASS
FUNCTION Main()
 LOCAL a := T(), b := T(), c := a
 ? a == a, a == b, a == c
RETURN NIL
