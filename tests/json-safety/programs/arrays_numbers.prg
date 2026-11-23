function Main()
local a := hb_jsonDecode('[1,2,3,4,5,6,7,8,9]')
local nested := hb_jsonDecode('["one",["two",[3,4,5,6,7]],[]]')
local bad := hb_jsonDecode('["allocated",["nested",1,2,3,4,5],bad]')
local exp1 := hb_jsonDecode("1e2")
local exp2 := hb_jsonDecode("1.25e2")
local exp3 := hb_jsonDecode("-1e-2")
local minint := hb_jsonDecode("-9223372036854775808")
? Len(a), a[1], a[5], a[9]
? hb_jsonEncode(a)
? hb_jsonEncode(nested)
? ValType(bad)
? exp1 == 100, exp2 == 125, exp3 == -0.01
? minint == -9223372036854775808
return nil
