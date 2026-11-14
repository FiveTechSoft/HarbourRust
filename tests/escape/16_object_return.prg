#include "hbclass.ch"
CREATE CLASS Box
 DATA value INIT 9
ENDCLASS
function make()
 local o := Box():New()
return o
function main()
 local returned := make()
 ? returned:value
return nil
