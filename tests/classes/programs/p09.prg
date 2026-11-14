#include "hbclass.ch"
CREATE CLASS T
   DATA x INIT 7
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
   ? "NEW-RAN"
return Self
function main()
   local o, p
   o := T()
   ? "after T(), x =", o:x
   p := T():New()
   ? "after New(), x =", p:x
return nil
