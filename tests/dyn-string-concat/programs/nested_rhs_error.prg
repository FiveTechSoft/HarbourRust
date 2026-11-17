function main()
local d,e
d := "owned"
try
? d+("x"+invalid())
catch e
? "caught"
end
? "after"
return nil
function invalid()
local n
return n
