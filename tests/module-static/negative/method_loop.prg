#include "hbclass.ch"
STATIC n := 1
CLASS Counter
METHOD Run()
ENDCLASS
METHOD Run() CLASS Counter
FOR n := 1 TO 3
? n
NEXT
RETURN NIL
PROCEDURE Main()
LOCAL o := Counter():New()
o:Run()
? n
RETURN
