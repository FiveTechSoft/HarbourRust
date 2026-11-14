#include "hbclass.ch"
CREATE CLASS T
   DATA a
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
return Self
function main()
   local o := T():New()
   ? o:a
   o:a := 9
   ? o:a
return nil
