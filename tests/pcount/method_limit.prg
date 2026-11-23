#include "hbclass.ch"
CREATE CLASS T
   METHOD Count()
ENDCLASS
METHOD Count() CLASS T
return pcount()
function main()
local o := T()
? o:Count()
return nil
