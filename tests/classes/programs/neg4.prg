#include "hbclass.ch"
CREATE CLASS A
   DATA x INIT 1
ENDCLASS
procedure main()
   local u
   u := A()
   ? u:x
return
