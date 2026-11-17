#include "hbclass.ch"
STATIC o := NIL
CREATE CLASS T
   DATA n INIT 3
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
return Self
function main()
   local a
   o := T():New()
   a := o
   ? o:n, readn(), a == o
   swapobj()
   ? o:n, readn(), a:n, a == o
return nil
function readn()
return o:n
function swapobj()
   o := T():New()
   o:n := 8
return nil
