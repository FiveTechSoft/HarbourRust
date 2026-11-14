function Main()
local e
try
Middle()
catch e
? "outer catch",ProcName(),ProcName(1)
finally
? "outer finally",ProcName()
end
? "after",ProcName()
return nil
function Middle()
try
Fail()
finally
? "inner finally",ProcName(),ProcName(1)
end
return nil
function Fail()
local a:={1}
local i:=2
? a[i]
return nil
