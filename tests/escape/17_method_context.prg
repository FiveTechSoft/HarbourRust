#include "hbclass.ch"
CREATE CLASS Alpha
 DATA first
 METHOD Set()
ENDCLASS
CREATE CLASS Beta
 DATA second INIT 2
ENDCLASS
METHOD Set() CLASS Alpha
 local payload := "alpha" + "data"
 ::first := payload
return Self
function main()
 local a := Alpha():New()
 local b := Beta():New()
 a:Set()
 ? a:first, b:second
return nil
