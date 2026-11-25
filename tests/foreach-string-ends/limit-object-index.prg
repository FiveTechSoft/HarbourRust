#include "hbclass.ch"
CLASS Test
 METHOD __enumIndex()
ENDCLASS
METHOD __enumIndex() CLASS Test
 ? "MUST-NOT-RUN"
RETURN 1
PROCEDURE Main()
 LOCAL s:="abc",v:=NIL,o:=Test():New()
 FOR EACH v IN s
 ? o:__enumIndex()
 NEXT
RETURN
