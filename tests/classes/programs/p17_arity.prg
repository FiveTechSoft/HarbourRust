#include "hbclass.ch"
CREATE CLASS T
   METHOD New() CONSTRUCTOR
   METHOD M(a, b)
ENDCLASS
METHOD New() CLASS T
return Self
METHOD M(a, b) CLASS T
   ? a
   ? b
return nil
function main()
   local o := T():New()
   o:M(1)
   o:M(1, 2)
return nil
