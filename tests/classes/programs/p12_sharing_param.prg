#include "hbclass.ch"
CREATE CLASS T
   DATA a INIT 1
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
return Self
function touch(o)
   o:a := 55
return nil
function main()
   local o := T():New()
   touch(o)
   ? o:a
return nil
