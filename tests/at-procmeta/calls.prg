procedure Main()
? At("A",Who())
? At(Where(),"abcabc")
return
function Who()
return ProcName(1)
function Where()
return Str(ProcLine(1))
