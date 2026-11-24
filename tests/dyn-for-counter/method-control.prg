#include "hbclass.ch"
CLASS Box
 METHOD Run()
ENDCLASS
METHOD Run() CLASS Box
 LOCAL n:=0
 ? ValType(n)
 FOR n:=1 TO 3
  ? n
 NEXT
RETURN n
PROCEDURE Main()
 LOCAL o:=Box():New()
 ? o:Run()
RETURN
