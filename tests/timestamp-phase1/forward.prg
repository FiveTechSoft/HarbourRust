function f(x)
return x
function main()
local t := hb_SToT("20261123"),a := {}
AAdd(a,f(t))
? hb_TToS(f(t)), hb_TToS(a[1]), HB_ISNUMERIC(t),HB_ISSTRING(t),HB_ISARRAY(t)
return nil
