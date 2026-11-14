#include "hbclass.ch"
CREATE CLASS T
   DATA a INIT 1
   METHOD New() CONSTRUCTOR
   METHOD Bump()
   METHOD Show()
ENDCLASS
METHOD New() CLASS T
return Self
METHOD Bump() CLASS T
   ::a += 10
return Self
METHOD Show() CLASS T
   ? "a is", ::a
return Self
function main()
   T():New():Bump():Bump():Show()
return nil
