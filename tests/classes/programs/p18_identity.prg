#include "hbclass.ch"
CREATE CLASS T
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
return Self
function main()
   local a := T():New()
   local b := T():New()
   local c := a
   ? a == a, a == b, a == c
return nil
