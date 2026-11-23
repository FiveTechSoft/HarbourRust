function SelectAndFail(p,fail)
local a := iif(p == NIL,{},p)
AAdd(a,9)
if fail
Break("expected")
endif
return Len(a)
function main()
local i,a := {},hits := 0
AAdd(a,1)
for i := 1 to 100
try
SelectAndFail(NIL,.T.)
catch
hits++
end
try
SelectAndFail(a,.T.)
catch
hits++
end
next
? hits,Len(a),a[101]
return nil
