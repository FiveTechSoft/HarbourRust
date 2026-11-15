#include "hbclass.ch"
CREATE CLASS T
DATA x INIT 2.500
METHOD New() CONSTRUCTOR
METHOD Read()
METHOD Put(f)
ENDCLASS
METHOD New() CLASS T
return Self
METHOD Read() CLASS T
return ::x
METHOD Put(f) CLASS T
::x:=f
return Self
procedure Main()
? work()
? hb_memcheck()
return
function work()
local a:=T():New()
local b:=T():New()
local x:=a:Read()
a:Put(3.140)
? x,a:x,b:x
a:x:=6.2500
? a:Read(),b:x
return 0
