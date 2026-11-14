function Main()
Caller()
? ProcName(),ProcName(1)
return nil
function Caller()
local e
try
Middle()
catch e
? ProcName(),ProcName(1),ProcLine()>0
Check()
end
? ProcName(),ProcName(1)
return nil
function Middle()
Fail()
return nil
function Check()
? ProcName(),ProcName(1),ProcName(2)
return nil
function Fail()
local a:={1}
local i:=2
? a[i]
return nil
