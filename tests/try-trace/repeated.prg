function Main()
local i:=0
local e
for i:=1 to 3
try
Fail()
catch e
? "caught",i,ProcName()
end
Check()
next
return nil
function Check()
? ProcName(),ProcName(1)
return nil
function Fail()
local a:={1}
local i:=2
? a[i]
return nil
