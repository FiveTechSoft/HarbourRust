procedure Main()
Work()
? hb_memcheck()
return
function Work()
local a:={1}
local e
try
? StrTran("abc","a","X",a[Idx()])
catch e
? e
end
return nil
function Idx()
return 2
