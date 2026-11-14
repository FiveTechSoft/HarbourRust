#include "hbclass.ch"
CREATE CLASS T
   DATA x INIT 11
   METHOD New() CONSTRUCTOR
   METHOD x()
ENDCLASS
METHOD New() CLASS T
return Self
METHOD x() CLASS T
return 99
function main()
   local o := T():New()
   ? o:x
   ? o:x()
return nil
