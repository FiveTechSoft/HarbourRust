function Copia(p)
local a := iif(p == NIL,{},p)
AAdd(a,"owned")
return Len(a)
function main()
local a := {}
? Copia(a)
return nil
