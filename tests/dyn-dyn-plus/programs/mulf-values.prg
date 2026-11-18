function main()
local a,b,c,d,e,r,z
try
a:=1.5
z:=0
b:=2
c:=0.25
d:=-3
? a*b
? b*a
? a*c
? b*d
? d*a
? a*z
? b*1000000
? c*c*b
r:=a*b
? r
r:=r*c
? r
r:=a*b*c*d
? r
catch e
? "ERR"
end
return nil
