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
   ? x
return nil
function main()
   local i,e
   for i := 1 to 500
         o:Echo("owned")
   next
   o := T():New()
   ? hold(o)
   ? o:n
return nil
function hold(x)
   o := T():New()
   o:n := 8
return x:n
