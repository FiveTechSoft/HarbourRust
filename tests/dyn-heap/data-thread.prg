#include "hbclass.ch"
CREATE CLASS FloatBox
DATA x INIT 2.500
METHOD New() CONSTRUCTOR
METHOD Read()
ENDCLASS
METHOD New() CLASS FloatBox
return Self
METHOD Read() CLASS FloatBox
return ::x
procedure main()
local a:=FloatBox():New()
local t,r
t:=hb_threadStart(@reader(),a)
? hb_threadJoin(t,@r),r
return
function reader(a)
return a:Read()
