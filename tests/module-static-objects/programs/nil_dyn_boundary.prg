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
   inspect(o)
   o := T():New()
   inspect(o)
   o := NIL
   inspect(o)
return nil
function inspect(p)
   ? p, ValType(p)
return nil
