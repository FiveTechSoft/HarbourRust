function main()
local d,e
d := 2
try
? d+effect()
catch e
? "caught"
end
? "after"
return nil
function effect()
? "right"
return "!"
