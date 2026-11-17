#include "hbclass.ch"
CREATE CLASS T
   DATA n INIT 0
   METHOD New() CONSTRUCTOR
   METHOD Wait()
ENDCLASS
METHOD New() CLASS T
return Self
METHOD Wait() CLASS T
   local d
   d := 0.0001
return d
function main()
   local o := T():New()
   local i
   for i := 1 to 500
      hb_idleSleep(o:Wait())
   next
   ? "done"
return nil
