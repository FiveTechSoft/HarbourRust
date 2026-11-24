function make()
local x := NIL
x := "own" + "ed"
return x
function main()
local i
for i := 1 to 100
hb_ISDATETIME(make())
HB_ISTIMESTAMP(upper("owned"))
next
? HB_ISDATETIME(NIL), HB_ISTIMESTAMP(1),HB_ISDATE(hb_SToT("20261123"))
return nil
