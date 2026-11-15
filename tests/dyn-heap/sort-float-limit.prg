procedure main()
local a:=makevalues()
ASort(a)
return
function makevalues()
local h:={=>}
h["one"]:=floating(2.500)
h["two"]:=floating(1.250)
return hb_HValues(h)
function floating(x)
return hb_PValue(1)
