function Copia(p)
local a := iif(p == NIL,{},p)
AAdd(a,9)
return Len(a)
function main()
local a := {}
? Copia(a)
hb_threadWaitForAll()
return nil
