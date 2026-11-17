#include "hbclass.ch"
CREATE CLASS T
   DATA s
   METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
return Self
function main()
local o := T():New()
o:s := "ab"
o:s := o:s+"cd"
? o:s, "prefix"+o:s
return nil
