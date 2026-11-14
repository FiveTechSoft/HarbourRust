procedure main()
? work()
? hb_memcheck()
return
function work()
local a:={1,"canary"}
local h:={"k"=>a[2]}
local j := {"z"=>hb_HGet(h,"k")}
? j["z"]
return 0
function owned()
local a:={1,"default"}
return a[2]
procedure show(v)
? v
return
