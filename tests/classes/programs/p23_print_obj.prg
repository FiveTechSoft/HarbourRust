#include "hbclass.ch"
CREATE CLASS T
   DATA a INIT 1
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
return Self
function main()
   local o := T():New()
   ? o
return nil
