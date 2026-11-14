#include "hbclass.ch"
CREATE CLASS T
   DATA a INIT 1
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
return Self
function main()
   local o1 := T():New()
   local o2 := o1
   o2:a := 77
   ? o1:a, o2:a
return nil
