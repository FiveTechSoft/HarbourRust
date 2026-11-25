#include "hbclass.ch"
CLASS Test
 METHOD __enumIsLast()
ENDCLASS
METHOD __enumIsLast() CLASS Test
 ? "MUST-NOT-RUN"
RETURN 1
PROCEDURE Main()
 LOCAL s:="abc",v:=NIL,o:=Test():New()
 FOR EACH v IN s
 ? o:__enumIsLast()
 NEXT
RETURN
