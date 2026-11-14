#include "hbclass.ch"
CREATE CLASS A
   DATA a INIT 1
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS A
return Self
CREATE CLASS B
   DATA b INIT 2
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS B
return Self
CREATE CLASS C INHERIT A, B
ENDCLASS
function main()
   local o := C():New()
   ? o:a, o:b
return nil
