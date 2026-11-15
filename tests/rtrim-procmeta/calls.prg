procedure Main()
? RTrim(Who())
? RTrim(Where())
return
function Who()
return ProcName(1)
function Where()
return Str(ProcLine(1))
