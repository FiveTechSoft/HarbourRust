function Main()
local e
begin sequence with {|err| Break(err)}
Middle()
recover using e
? "outer catch",ProcName(),ProcName(1)
always
? "outer finally",ProcName()
end sequence
? "after",ProcName()
return nil
function Middle()
begin sequence with {|err| Break(err)}
Fail()
always
? "inner finally",ProcName(),ProcName(1)
end sequence
return nil
function Fail()
local a:={1}
local i:=2
? a[i]
return nil
