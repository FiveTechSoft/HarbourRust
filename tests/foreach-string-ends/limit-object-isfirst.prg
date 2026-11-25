#include "hbclass.ch"
CLASS Test
 METHOD __enumIsFirst()
ENDCLASS
METHOD __enumIsFirst() CLASS Test
 ? "MUST-NOT-RUN"
RETURN 1
PROCEDURE Main()
 LOCAL s:="abc",v:=NIL,o:=Test():New()
 FOR EACH v IN s
 ? o:__enumIsFirst()
 NEXT
RETURN
