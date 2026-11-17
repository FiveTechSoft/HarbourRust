function main()
local d,e,i,hits:=0
d:="owned"
for i:=1 to 3
try
Break(d+"!")
catch e
? e
hits+=1
end
e:=NIL
next
? hits
return nil
