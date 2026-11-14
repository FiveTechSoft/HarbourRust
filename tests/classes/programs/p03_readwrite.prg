#include "hbclass.ch"
CREATE CLASS T
   DATA a INIT 0
   DATA s INIT ""
   DATA l INIT .F.
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
return Self
function main()
   local o := T():New()
   o:a := 42
   o:s := "abc"
   o:l := .T.
   ? o:a, o:s, o:l
   o:a += 8
   ? o:a
return nil
