#include "hbclass.ch"
CREATE CLASS Base
   DATA b INIT 7
   METHOD New() CONSTRUCTOR
   METHOD Who()
ENDCLASS
METHOD New() CLASS Base
return Self
METHOD Who() CLASS Base
   ? "base"
return Self
CREATE CLASS Child INHERIT Base
   METHOD Who()
ENDCLASS
METHOD Who() CLASS Child
   ? "child", ::b
return Self
function show(o)
   o:Who()
return nil
function main()
   local o := Child():New()
   show(o)
return nil
