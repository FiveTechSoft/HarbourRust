#include "hbclass.ch"
CLASS Test
 METHOD __enumIsLast()
ENDCLASS
METHOD __enumIsLast() CLASS Test
 ? "MUST-NOT-RUN"
RETURN 1
PROCEDURE Main()
 LOCAL a:={Test():New()},s:="abc",o:=NIL,v:=NIL
 FOR EACH o IN a
 FOR EACH v IN s
 ? o:__enumIsLast()
 NEXT
 NEXT
RETURN
