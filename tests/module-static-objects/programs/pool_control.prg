#include "hbclass.ch"
CREATE CLASS T
   DATA n INIT 3
   METHOD New() CONSTRUCTOR
   METHOD Echo(x)
ENDCLASS
METHOD New() CLASS T
return Self
METHOD Echo(x) CLASS T
return ::n + x
function main()
   local i,a
   for i := 1 to 500
      a := T():New()
      ? a:n,a:n
   next
return nil
