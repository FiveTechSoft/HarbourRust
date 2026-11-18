function main()
local a,s,n,t,e,r
a:=1.5
s:="x"
n:=NIL
t:=.T.
try
r:=a*s
? "no", r
catch e
? "ERR1"
end
try
r:=s*a
? "no", r
catch e
? "ERR2"
end
try
r:=a*n
? "no", r
catch e
? "ERR3"
end
try
r:=a*t
? "no", r
catch e
? "ERR4"
end
try
r:=n*a
? "no", r
catch e
? "ERR5"
end
return nil
