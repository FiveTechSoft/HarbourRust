procedure Main()
? Trim(Who())
? Trim(Where())
return
function Who()
return ProcName(1)
function Where()
return Str(ProcLine(1))
