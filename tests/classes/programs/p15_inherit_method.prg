#include "hbclass.ch"
CREATE CLASS Base
   DATA a INIT 4
   METHOD New() CONSTRUCTOR
   METHOD Get()
ENDCLASS
METHOD New() CLASS Base
return Self
METHOD Get() CLASS Base
return ::a * 100
CREATE CLASS Child INHERIT Base
ENDCLASS
function main()
   local o := Child():New()
   ? o:Get()
return nil
