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
   ? ValType(o), o
   o := T():New()
   ? ValType(o)
   a := o
   ? o:n, readn(), a == o
   swapobj()
   ? o:n, readn(), a:n, a == o
   o := NIL
   ? ValType(o), o, a:n
return nil
function readn()
return o:n
function swapobj()
   o := T():New()
   o:n := 8
return nil
