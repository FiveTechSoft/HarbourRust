#include "hbclass.ch"
STATIC n := 5
CLASS Counter
   METHOD Bump()
ENDCLASS
METHOD Bump() CLASS Counter
   n := n+1
RETURN n
FUNCTION ReadN()
RETURN n
PROCEDURE Main()
   LOCAL o := Counter():New()
   ? ReadN(),o:Bump(),ReadN(),o:Bump()
RETURN
