function main()
local e
try
? "x"+bad()
catch e
? "caught"
end
? "after"
return nil
function bad()
local d
d := 1.25
return d
