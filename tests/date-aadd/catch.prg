function main()
local a := {}, i := 2
AAdd(a,SToD("20261123"))
try
? a[i]
catch
? ValType(a[1]),a[1]
end
return nil
