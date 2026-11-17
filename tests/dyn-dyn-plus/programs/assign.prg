function main()
local a,b,c,s,e
try
a:="p"
b:="q"
s:=a+b
s:=s+a+b
? s
catch e
? "ERR"
end
return nil
