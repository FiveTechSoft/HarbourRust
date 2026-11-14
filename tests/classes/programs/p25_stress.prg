#include "hbclass.ch"
CREATE CLASS Node
   DATA v INIT 0
   METHOD New() CONSTRUCTOR
   METHOD Bump()
ENDCLASS
METHOD New() CLASS Node
return Self
METHOD Bump() CLASS Node
   ::v := ::v + 1
return Self
function main()
   local acc := 0
   local i
   local o
   for i := 1 to 2000
      o := Node():New()
      o:Bump()
      acc := acc + o:v
   next
   ? "acc", acc
return nil
