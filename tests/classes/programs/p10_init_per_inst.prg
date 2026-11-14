#include "hbclass.ch"
function nextid()
   static n := 0
   n += 1
return n
CREATE CLASS T
   DATA id INIT nextid()
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
return Self
function main()
   local a := T():New()
   local b := T():New()
   ? a:id, b:id
return nil
