#include "hbclass.ch"
CREATE CLASS T
   DATA a INIT 3
   METHOD New() CONSTRUCTOR
   METHOD Double()
ENDCLASS
METHOD New() CLASS T
return Self
METHOD Double() CLASS T
   ? "doubling", ::a
return ::a * 2
function main()
   local o := T():New()
   ? "got", o:Double()
return nil
