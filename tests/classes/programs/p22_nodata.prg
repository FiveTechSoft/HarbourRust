#include "hbclass.ch"
CREATE CLASS T
   METHOD New() CONSTRUCTOR
   METHOD Ping()
ENDCLASS
METHOD New() CLASS T
return Self
METHOD Ping() CLASS T
return "pong"
function main()
   local a := T():New()
   a := T():New()
   ? a:Ping()
   ? a == a
return nil
