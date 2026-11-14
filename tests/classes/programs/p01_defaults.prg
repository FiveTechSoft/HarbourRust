#include "hbclass.ch"
CREATE CLASS T
   DATA a INIT 5
   DATA s INIT "hey"
   DATA l INIT .T.
   DATA f INIT 2.5
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
return Self
function main()
   local o := T():New()
   ? o:a, o:s, o:l, o:f
return nil
