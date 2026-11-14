function Main()
Nest(256)
? "after",ProcName()
return nil
function Nest(n)
local e
if n>0
try
Nest(n-1)
catch e
? "caught",ProcName(),ProcName(1)
end
else
Fail()
endif
return nil
function Fail()
local a:={1}
local i:=2
? a[i]
return nil
