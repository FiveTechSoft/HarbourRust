function main()
local a,b,e
try
a:=g("p")
b:=g("q")
? a+b
catch e
? "ERR"
end
return nil
function g(x)
return x
