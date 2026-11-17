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
   local d2, i
   for i := 1 to 500
      d2 := o:Wait()
      hb_idleSleep(0.0001)
   next
   ? "done"
return nil
