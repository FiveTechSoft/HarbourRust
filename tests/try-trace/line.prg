function Main()
local e
try
Fail()
catch e
? ProcName(),ProcLine(),ProcName(1)
end
? ProcName(),ProcLine()
return nil
function Fail()
local a:={1}
local i:=2
? a[i]
return nil
