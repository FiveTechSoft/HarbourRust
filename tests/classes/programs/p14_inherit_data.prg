#include "hbclass.ch"
CREATE CLASS Base
   DATA a INIT 10
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS Base
return Self
CREATE CLASS Child INHERIT Base
   DATA c INIT 20
ENDCLASS
function main()
   local o := Child():New()
   ? o:a, o:c
   o:a := 33
   ? o:a
return nil
