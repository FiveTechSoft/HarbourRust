#include "hbclass.ch"
CREATE CLASS Box
 DATA value
 METHOD Put()
 METHOD Read()
ENDCLASS
METHOD Put() CLASS Box
 local payload := "kept" + "field"
 ::value := payload
return Self
METHOD Read() CLASS Box
 local observed := "local" + "only"
 ? observed, ::value
return nil
function main()
 local o := Box():New()
 o:Put()
 o:Read()
return nil
