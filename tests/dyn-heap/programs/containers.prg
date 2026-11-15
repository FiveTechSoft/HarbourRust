procedure main()
? work()
? hb_memcheck()
return
function value(f)
return hb_PValue(1)
function work()
local x:=value(2.500)
local h:={"a"=>x,"b"=>value(3.140)}
local j:=hb_HClone(h)
local a:=hb_HValues(h)
? h["a"],j["b"],a[1],a[2]
h["a"]:=value(4.50)
? j["a"],h["a"]
hb_HFill(h,x)
hb_HDel(h,"a")
hb_HDelAt(j,1)
hb_HClear(h)
? a[1],j["b"]
return 0
