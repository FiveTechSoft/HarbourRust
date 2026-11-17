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
   local t
   o := T():New()
   t := hb_threadStart(@worker())
   hb_threadJoin(t)
return nil
function worker()
   o := T():New()
return nil
