#include "hbclass.ch"
CREATE CLASS T
   METHOD M()
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD M() CLASS T
   local d
   d := "send-str"
   return d
METHOD New() CLASS T
return Self
function main()
   local o := T():New()
   local i
   for i := 1 to 500
      o:M()
   next
   ? "done"
return nil
