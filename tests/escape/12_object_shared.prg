#include "hbclass.ch"
CREATE CLASS Box
 DATA n INIT 1
ENDCLASS
function main()
 local first := Box():New()
 local alias := first
 alias:n := 7
 ? first:n, alias:n
return nil
