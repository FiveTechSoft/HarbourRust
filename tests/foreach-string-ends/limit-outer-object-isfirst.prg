#include "hbclass.ch"
CLASS Test
 METHOD __enumIsFirst()
ENDCLASS
METHOD __enumIsFirst() CLASS Test
 ? "MUST-NOT-RUN"
RETURN 1
PROCEDURE Main()
 LOCAL a:={Test():New()},s:="abc",o:=NIL,v:=NIL
 FOR EACH o IN a
 FOR EACH v IN s
 ? o:__enumIsFirst()
 NEXT
 NEXT
RETURN
