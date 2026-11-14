function Main()
local e
try
Check()
catch e
? "unexpected"
finally
? "finally",ProcName()
end
? "after",ProcName(),ProcName(1)
return nil
function Check()
? ProcName(),ProcName(1)
return nil
