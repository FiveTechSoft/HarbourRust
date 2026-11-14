#include "hbclass.ch"
function mark()
   ? "INIT-RUN"
return 5
CREATE CLASS T
   DATA a INIT mark()
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
return Self
function main()
   local a := T():New()
   local b := T():New()
   ? a:a, b:a
return nil
