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
   local keep := Upper(x)
   hits += 1
return nil
function main()
   local i,e,x := Space(7), a := o, catches := 0
   for i := 1 to 3
      x := Space(7)
      try
         a:Echo("owned")
      catch e
         catches += 1
      end
      x := Space(7)
   next
   o := T():New()
   ? hits, catches
return nil
