function main()
local a,b,s,e
try
s := f("1")+f("2")
? s
s := s+f("3")+f("4")
? s
catch e
? "ERR"
end
a := "L"
try
s := a+boom()
? "no"
catch e
? "CAUGHT",a
end
return nil
function f(x)
? "f",x
return x
function boom()
break("boom")
return "never"
