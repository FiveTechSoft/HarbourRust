procedure main()
? work()
? hb_memcheck()
return
function work()
local a := {1,"canary"}
local h := {"k"=>a[2]}
local before := hb_memcheck()
switch hb_HGetDef(h,"k")
case "canary"
? "matched"
exit
otherwise
? "BAD"
endswitch
? hb_memcheck()-before
return 0
