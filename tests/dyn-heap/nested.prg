EXTERNAL DYN_OUTER,DYN_INNER
procedure main()
? work()
? hb_memcheck()
return
function callback()
DYN_INNER()
return 33
function work()
local x:=DYN_OUTER({||callback()},2.5,17)
? x
return 0
