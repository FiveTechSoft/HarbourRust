#include "hbclass.ch"
STATIC o := NIL
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
   local a
   o := T():New()
   a := {o}
return nil
