procedure main()
local s := Who()
? s, Empty(s), Len(s)
Other()
return
function Who()
return ProcName()
function Other()
local b := {|| OutStd(ProcName(), ProcName(0)), 2}
? Eval(b), ProcName()
return NIL
