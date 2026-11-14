function Main()
local e
? ProcName()
begin sequence with {|err| Break(err)}
Fail()
recover using e
? "caught"
end sequence
? ProcName(),ProcName(1)
return nil
function Fail()
local a:={1}
local i:=2
? a[i]
return nil
