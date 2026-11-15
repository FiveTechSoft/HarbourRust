procedure Main()
? Abs(Who())
? Abs(Where())
return
function Who()
return Len(ProcName(1))
function Where()
return ProcLine(1)
