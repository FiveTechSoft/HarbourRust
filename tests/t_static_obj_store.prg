#include "hbclass.ch"
STATIC o := 0
CREATE CLASS T
   DATA n INIT 3
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
return Self
function main()
   o := T():New()
   ? o:n
return nil
