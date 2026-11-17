#include "hbclass.ch"
STATIC o := NIL
CREATE CLASS T
   DATA n INIT 3
   METHOD New() CONSTRUCTOR
   METHOD Echo(x)
ENDCLASS
METHOD New() CLASS T
return Self
METHOD Echo(x) CLASS T
return ::n + x
function main()
   local i,a,b
   for i := 1 to 500
      o := T():New()
      a := o
      o := o
      b := getobj()
      o := NIL
      ? a:n,b:n
   next
return nil
function getobj()
return o
