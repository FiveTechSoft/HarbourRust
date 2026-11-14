#include "hbclass.ch"
CREATE CLASS A
   DATA x INIT 1
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS A
return Self
CREATE CLASS B
   DATA x INIT 2
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS B
return Self
function touch(o)
   o:x := 9
return nil
function main()
   local o := A():New()
   touch(o)
return nil
