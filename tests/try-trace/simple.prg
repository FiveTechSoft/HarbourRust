function Main()
local e
? ProcName()
try
Fail()
catch e
? "caught"
end
? ProcName(),ProcName(1)
return nil
function Fail()
local a:={1}
local i:=2
? a[i]
return nil
