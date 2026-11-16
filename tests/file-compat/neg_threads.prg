procedure Main()
local h := hb_threadStart(@worker())
set path to "search"
hb_threadJoin(h)
return
procedure worker()
return
