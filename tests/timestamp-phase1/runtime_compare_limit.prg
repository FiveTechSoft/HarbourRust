function equal(a,b)
return a == b
function main()
local t := hb_SToT("20261123")
try
? equal(t,t)
catch
? "comparison rejected"
end
return nil
