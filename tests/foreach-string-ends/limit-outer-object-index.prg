#include "hbclass.ch"
CLASS Test
 METHOD __enumIndex()
ENDCLASS
METHOD __enumIndex() CLASS Test
 ? "MUST-NOT-RUN"
RETURN 1
PROCEDURE Main()
 LOCAL a:={Test():New()},s:="abc",o:=NIL,v:=NIL
 FOR EACH o IN a
 FOR EACH v IN s
 ? o:__enumIndex()
 NEXT
 NEXT
RETURN
