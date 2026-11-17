function main()
local e
try
? bad()+"x"
catch e
? "caught"
end
? "after"
return nil
function bad()
local d
d := {1,NIL}
return d
