procedure Main()
Work()
? hb_memcheck()
return
function Work()
local c:=Replicate("A",3000)
local a:={1}
local e
try
? PadR(c,a[BadIndex()])
catch e
? e
end
return nil
function BadIndex()
return 2
