function main()
local a,b,c,s,e
try
a:="1"
b:="2"
c:=a
a:=b
b:=c
? a+b
catch e
? "ERR"
end
return nil
