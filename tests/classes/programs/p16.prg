#include "hbclass.ch"
function mark(c)
   ? "INIT", c
return c
CREATE CLASS Base
   DATA b INIT mark("P")
ENDCLASS
CREATE CLASS Child INHERIT Base
   DATA c INIT mark("C")
ENDCLASS
function main()
   local o := Child():New()
   ? "done", o:b, o:c
return nil
