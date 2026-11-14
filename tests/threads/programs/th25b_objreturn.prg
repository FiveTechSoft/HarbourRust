#include "hbclass.ch"
CREATE CLASS T
   DATA n INIT 7
ENDCLASS
procedure Main()
   local th, r, th2
   th := hb_threadStart(@W())
   hb_threadJoin(th, @r)
   ? "type", ValType(r)
   th2 := hb_threadStart(@Bump(), r)
   hb_threadJoin(th2)
return
function W()
   local o := T():New()
   o:n := 99
return o
procedure Bump(o)
   o:n := 42
   ? "reused-after-crossing", o:n
return
