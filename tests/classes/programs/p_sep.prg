#include "hbclass.ch"
CREATE CLASS T
   DATA a INIT 1
ENDCLASS
PROCEDURE Main()
   LOCAL o
   o := T()
   ? "x", o, "y"
   ? "x", o
   o := NIL
   ? "x", o, "y"
   ? o, "y"
RETURN
