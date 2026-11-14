procedure Main()
Work()
? hb_memcheck()
return
function Work()
local a:={1}
local e
try
? SubStr("ABC",a[BadIndex()],1)
catch e
? e
end
return nil
function BadIndex()
return 2
