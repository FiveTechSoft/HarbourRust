#include "hbclass.ch"
CREATE CLASS Box
 METHOD Read(x)
 METHOD Take(x)
ENDCLASS
METHOD Read(x) CLASS Box
 ? x + "!"
return nil
METHOD Take(x) CLASS Box
return x + "!"
function main()
 local o := Box():New()
 local observed := "read" + "only"
 local moved := "out" + "ward"
 o:Read(observed)
 ? o:Take(moved)
return nil
