function main()
local d,e
d := "owned"
try
? d+boom()
catch e
? e
end
? "after"
return nil
function boom()
break("boom")
return "never"
