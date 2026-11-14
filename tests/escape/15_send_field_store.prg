#include "hbclass.ch"
CREATE CLASS Box
 DATA value
ENDCLASS
function main()
 local o := Box():New()
 local kept := "stored" + "value"
 local observed := "just" + "print"
 o:value := kept
 ? o:value, observed
return nil
