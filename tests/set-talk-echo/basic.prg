procedure Main()
Work()
return
function Work()
local x:=2
set talk ON
set echo ON
? "on",x*3
set talk OFF
set echo OFF
? "off",x+4
SeT TaLk oN
SeT EcHo oFf
? "mix",x
if x==2
set talk OFF
set echo ON
? "nested"
endif
return
