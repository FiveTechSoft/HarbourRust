#include "hbclass.ch"
CREATE CLASS TCuenta
   DATA saldo INIT 0
ENDCLASS
PROCEDURE Main()
   LOCAL a, b
   a := TCuenta()
   b := a
   b:saldo := 42
   ? a:saldo
   ? a == b
   a := NIL
   b := NIL
RETURN
