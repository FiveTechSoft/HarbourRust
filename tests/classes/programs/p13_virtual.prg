#include "hbclass.ch"
CREATE CLASS Base
   METHOD New() CONSTRUCTOR
   METHOD Who()
ENDCLASS
METHOD New() CLASS Base
return Self
METHOD Who() CLASS Base
return "base"
CREATE CLASS Child INHERIT Base
   METHOD Who()
ENDCLASS
METHOD Who() CLASS Child
return "child"
function main()
   local b := Base():New()
   local c := Child():New()
   ? b:Who(), c:Who()
return nil
