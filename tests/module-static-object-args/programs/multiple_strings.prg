#include "hbclass.ch"
STATIC o := NIL
STATIC hits := 0
CREATE CLASS T
   METHOD New() CONSTRUCTOR
   METHOD Echo(x,y,z)
ENDCLASS
METHOD New() CLASS T
return Self
METHOD Echo(x,y,z) CLASS T
   local a := Upper(x), b := Upper(y), c := Upper(z)
   hits += 1
return nil
function main()
   local i,e,x := Space(7), a := o, catches := 0
   o := T():New()
   a := o
   for i := 1 to 3
      x := Space(7)
      try
         a:Echo(x, Lower("two"), Space(3))
      catch e
         catches += 1
      end
      x := Space(7)
   next
   ? hits, catches
return nil
