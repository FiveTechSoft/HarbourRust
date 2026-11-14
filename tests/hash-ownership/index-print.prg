procedure main()
? work()
? hb_memcheck()
return
function work()
local a := {1,"canary"}
local h := {"k"=>a[2]}
local before := hb_memcheck()
? h["k"]
? hb_memcheck()-before
return 0
