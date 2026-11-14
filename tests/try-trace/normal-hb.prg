function Main()
local e
begin sequence with {|err| Break(err)}
Check()
recover using e
? "unexpected"
always
? "finally",ProcName()
end sequence
? "after",ProcName(),ProcName(1)
return nil
function Check()
? ProcName(),ProcName(1)
return nil
