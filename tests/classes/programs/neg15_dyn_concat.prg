#include "hbclass.ch"
CREATE CLASS T
   DATA s INIT "ab"
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
return Self
function main()
   local o := T():New()
   o:s := o:s + "cd"
   ? o:s
return nil
