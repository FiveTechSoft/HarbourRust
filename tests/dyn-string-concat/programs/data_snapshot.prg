#include "hbclass.ch"
CREATE CLASS T
DATA s
METHOD New() CONSTRUCTOR
ENDCLASS
METHOD New() CLASS T
return Self
function main()
local o := T():New()
o:s := "old"
? o:s+change(o)
? o:s
return nil
function change(o)
o:s := "new"
return "!"
