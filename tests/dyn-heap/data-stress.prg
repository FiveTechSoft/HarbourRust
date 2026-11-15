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
local i:=0
for i:=1 to 200
onebox()
next
? hb_memcheck()
return
procedure onebox()
local a:=FloatBox():New()
local b:=FloatBox():New()
local x:=a:Read()
a:x:=3.140
b:x:=x
return
