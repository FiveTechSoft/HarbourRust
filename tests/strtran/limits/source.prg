procedure Main()
Work()
? hb_memcheck()
return
function Work()
local a:={1}
local e
try
? StrTran("abc",SubStr("a",a[Idx()],1))
catch e
? e
end
return nil
function Idx()
return 2
