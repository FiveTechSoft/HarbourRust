procedure main()
local b := {|| OutStd(ProcName()), 1}
? ProcName(), ProcName(0)
MixCase()
? Eval(b)
return
static function MixCase()
? ProcName(), ProcName(0)
return NIL
