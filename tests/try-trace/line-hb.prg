function Main()
local e
begin sequence with {|err| Break(err)}
Fail()
recover using e
? ProcName(),ProcLine(),ProcName(1)
end sequence
? ProcName(),ProcLine()
return nil
function Fail()
local a:={1}
local i:=2
? a[i]
return nil
